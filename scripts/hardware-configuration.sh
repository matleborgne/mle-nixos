#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Génère le module NixOS décrivant le matériel d'une machine
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Usage : hardware-configuration.sh [nom-de-l-hôte]
#
# Sortie : secrets/hardware/hardware-configuration-<hôte>.nix
#
# Le fichier généré déclare l'option
#     mle.secrets."hardware-<hôte>".enable
# à activer dans le rôle correspondant (roles/<rôle>.nix) :
#     mle.secrets.hardware-<hôte>.enable = true;
#
# Sans argument, l'hôte est lu dans /etc/hostname. Pendant une
# installation depuis l'ISO, /etc/hostname est celui de l'ISO :
# passez alors le nom du rôle cible en argument (ex : nix-n2).
#
# AVANT DE L'EXÉCUTER
#   1. Ouvrir les partitions LUKS (cryptsetup open ...)
#   2. Monter toutes les partitions, y compris les mount-bind

set -euo pipefail
PATH=$PATH:/run/current-system/sw/bin


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
repo=$( dirname "$current" )

host="${1:-$(cat /etc/hostname)}"
outdir="$repo/secrets/hardware"
outfile="$outdir/hardware-configuration-$host.nix"
tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT

keyfile="/etc/keys/keyfile.key" # change with your value here

# Pendant une installation, le dépôt est sous /mnt/etc/nixos/build :
# on en déduit le préfixe (/mnt) à retirer de tous les chemins.
case "$repo" in
  */etc/nixos/build) prefix="${repo%/etc/nixos/build}" ;;
  *)                 prefix="" ;;
esac


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Fonctions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

die()  { echo "Erreur : $*" >&2; exit 1; }
warn() { echo "Attention : $*" >&2; }
out()  { cat >> "$tmpfile"; }

# /mnt/boot -> /boot ; /mnt -> /
strip_prefix() {
  local p="${1#"$prefix"}"
  printf '%s' "${p:-/}"
}

# UUID de la partition chiffrée qui se cache derrière un mapping LUKS
luks_uuid() {
  local dev
  dev=$(cryptsetup status "$1" 2>/dev/null | awk '/device:/ {print $2}' || true)

  if [ -n "$dev" ] && blkid -o value -s UUID "$dev" 2>/dev/null; then
    return
  fi
  # Repli : nom standard luks-<UUID>
  echo "${1#luks-}"
}

# Bloc nix "luks.devices" pour un mapping donné
luks_block() {
  out <<EOF
      luks.devices."$1" = {
        device = "/dev/disk/by-uuid/$(luks_uuid "$1")";
        allowDiscards = true;
        preLVM = true;
        keyFile = "/keyfile1.bin";
      };

EOF
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Analyse du disque racine
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rootmount="${prefix:-/}"
rootid=$(findmnt --noheadings --output UUID --mountpoint "$rootmount" || true)
[ -n "$rootid" ] || die "aucune partition montée sur $rootmount (montez-la d'abord)"

# Nom et type du périphérique qui porte le système de fichiers racine
# (crypt = LUKS simple ; raid1, raid5... = RAID, éventuellement sur LUKS)
rootinfo=$(lsblk --raw --noheadings --output UUID,NAME,TYPE \
  | awk -v u="$rootid" '$1 == u { print $2, $3; exit }')
rootname="" ; roottype=""
read -r rootname roottype <<< "$rootinfo" || true
roottype="${roottype%%[0-9]*}"

# Mappings LUKS déchiffrés par l'initrd (donc à ne pas mettre dans crypttab)
initrd_luks=()

case "$roottype" in
  crypt)
    initrd_luks+=("$rootname")
    ;;
  raid)
    # Chaque membre du RAID est un mapping LUKS : /proc/mdstat -> /sys/block/<dm>/dm/name
    while read -r member; do
      [ -r "/sys/block/$member/dm/name" ] && initrd_luks+=("$(cat "/sys/block/$member/dm/name")")
    done < <(awk -v m="$rootname" '$1 == m { for (i = 5; i <= NF; i++) print $i }' /proc/mdstat \
               | sed 's/\[.*//')
    ;;
esac


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Début du module
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

out <<EOF
{ config, lib, pkgs, ... }:

# Fichier généré par scripts/hardware-configuration.sh
# Ne pas modifier à la main : relancer le script.

let
  host = "$host";
in
{

  options.mle.secrets."hardware-\${host}".enable = lib.mkOption {
    description = "Configure hardware of \${host}";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.secrets."hardware-\${host}".enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # FSTAB
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    fileSystems = {

EOF


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Systèmes de fichiers
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

while read -r source uuid target fstype options fsroot; do

  # Ligne incomplète (UUID absent -> colonnes décalées) : on l'ignore
  [ -n "$fsroot" ] || continue

  target=$(printf '%b' "$target")    # \x20 -> espace

  # Pendant une installation, ne garder que ce qui est sous /mnt
  if [ -n "$prefix" ]; then
    case "$target" in
      "$prefix"|"$prefix"/*) ;;
      *) continue ;;
    esac
  fi
  mountpoint=$(strip_prefix "$target")

  # Exclusions : lecture seule, systèmes distants/FUSE, montages temporaires
  case ",$options," in *,ro,*) continue ;; esac
  case "$fstype" in fuse*|*gocryptfs*|*sshfs*) continue ;; esac
  case "$mountpoint" in /run/media/*|*/resolv*) continue ;; esac

  device="/dev/disk/by-uuid/$uuid"

  # Mount-bind : le montage ne part pas de la racine du système de fichiers.
  # (btrfs : les sous-volumes passent par l'option subvol=, pas par un bind)
  if [ "$fsroot" != "/" ] && [ "$fstype" != "btrfs" ]; then
    base=$(findmnt --raw --noheadings --source "$source" --output TARGET,FSROOT \
             | awk '$2 == "/" { print $1; exit }' || true)

    if [ -z "$base" ]; then
      warn "$mountpoint : montage bind sans source identifiable, ignoré"
      continue
    fi

    base=$(strip_prefix "$(printf '%b' "$base")")
    device="${base%/}$fsroot"
    fstype="none"
    options="bind"
  fi

  # "rw,noatime" -> [ "rw" "noatime" ]
  IFS=, read -ra optlist <<< "$options"
  optnix=""
  for o in "${optlist[@]}"; do optnix+="\"$o\" "; done

  out <<EOF
      "$mountpoint" = {
        device = "$device";
        fsType = "$fstype";
        options = [ ${optnix}];
      };

EOF

done < <(findmnt --real --raw --noheadings --uniq --nofsroot \
           --output SOURCE,UUID,TARGET,FSTYPE,OPTIONS,FSROOT)

out <<EOF
    };

EOF


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRYPTTAB : disques chiffrés montés, hors disque racine
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

crypttab=""
while read -r name; do
  [ -n "$name" ] || continue

  skip=false
  for r in "${initrd_luks[@]}"; do [ "$r" = "$name" ] && skip=true; done
  $skip && continue

  crypttab+="        $name /dev/disk/by-uuid/$(luks_uuid "$name") $keyfile luks"$'\n'
done < <(lsblk --list --noheadings --output NAME \
           --filter 'MOUNTPOINTS =~ "/" AND NAME =~ "^luks-"' | sort -u)

if [ -n "$crypttab" ]; then
  out <<EOF
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # CRYPTTAB
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.etc.crypttab = {
      enable = true;
      text = ''
$crypttab      '';
    };

EOF
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Déchiffrement du disque racine (initrd)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ "${#initrd_luks[@]}" -gt 0 ]; then
  out <<EOF
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # ROOT DISK ENCRYPTION
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.initrd = {

EOF

  for name in "${initrd_luks[@]}"; do luks_block "$name"; done

  out <<EOF
      secrets = {
        "keyfile1.bin" = "$keyfile";
      };

    };

EOF
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Matériel détecté
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

out <<EOF
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # OTHER HARDWARE AUTOMATIONS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EOF

# Point de montage UEFI (/boot/efi ; /efi ; autre)
efi=$(findmnt --noheadings --raw --real --uniq --nofsroot --output TARGET \
        | grep -e "efi" | head -n 1 || true)
if [ -n "$efi" ]; then
  out <<EOF
    boot.loader.efi.efiSysMountPoint = "$(strip_prefix "$efi")";

EOF
fi

# Liste PCI (absente de certains environnements minimaux)
pci=""
if command -v lspci > /dev/null; then pci=$(lspci); fi

# Carte réseau Realtek RTL8125
if grep -i "ethernet" <<< "$pci" | grep -qi "RTL8125"; then
  echo "    mle.hardware.rtl8125.enable = true;" | out
  echo "" | out
fi

# Microcode et firmware du CPU
case "$(grep -m1 vendor_id /proc/cpuinfo | awk '{ print $NF }')" in
  AuthenticAMD|AMD|amd)       echo "    mle.hardware.amdcpu.enable = true;"   | out ; echo "" | out ;;
  GenuineIntel|Intel|intel)   echo "    mle.hardware.intelcpu.enable = true;" | out ; echo "" | out ;;
esac

# Carte graphique (priorité Nvidia > AMD > Intel)
vga=$(grep "VGA" <<< "$pci" || true)
if grep -qi "Nvidia" <<< "$vga"; then echo "    mle.hardware.nvidia.enable = true;"   | out ; echo "" | out
elif   grep -qi "AMD"    <<< "$vga"; then echo "    mle.hardware.amdgpu.enable = true;"   | out ; echo "" | out
elif grep -qi "Intel"  <<< "$vga"; then echo "    mle.hardware.intelgpu.enable = true;" | out ; echo "" | out
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Swapfile et hibernation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

swapfile="/var/swap/swapfile"
ramsize=$(( $(awk '/MemTotal/ { print $2 }' /proc/meminfo) / 1024 ))

out <<EOF
    swapDevices = [{
      device = "$swapfile";
      size = $ramsize;
    }];

    powerManagement.enable = true;

EOF

# Le décalage de reprise n'existe que si le swapfile existe déjà
# (absent lors d'une première installation : NixOS le crée au premier boot)
offset=""
if [ -f "$prefix$swapfile" ]; then
  sudo=""; [ "$(id -u)" -ne 0 ] && sudo="sudo"
  offset=$($sudo filefrag -v "$prefix$swapfile" \
             | awk '$1 == "0:" { sub(/\.\..*/, "", $4); print $4; exit }' || true)
fi

if [ -n "$offset" ]; then
  out <<EOF
    boot.kernelParams = [ "resume_offset=$offset" ];
    boot.resumeDevice = "/dev/disk/by-uuid/$rootid";

EOF
else
  warn "swapfile absent : hibernation non configurée (relancer le script après le premier boot)"
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Fin du module et écriture du fichier
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

out <<EOF
  };

}
EOF

mkdir -p "$outdir"
install -m 0644 "$tmpfile" "$outfile"

echo "Module écrit : $outfile"
echo "À activer dans le rôle : mle.secrets.hardware-$host.enable = true;"
