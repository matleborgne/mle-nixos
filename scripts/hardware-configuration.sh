#!/bin/bash

#set -x
current=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
hardwarefile="$current/../secrets/hardware-configuration.nix"

# TODO BEFORE EXECUTING HARDWARE SCRIPT

# 1. Open luks partition with correct name
# device="/dev/sda1"
# cryptsetup open "$device" "luks-$(blkid $device -o value -s UUID)"

# 2. Mount all partitions including mount-bind


# First lines
echo "{ config, lib, pkgs, ... }:
{

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # FSTAB
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fileSystems = {
    " > "$hardwarefile"


# Loop for filesystems - fstab
if [ $(findmnt --real --raw | grep '/ ' | wc -l) -gt 0 ]; then
  fstab=$(findmnt --noheadings --real --raw --uniq --nofsroot --output SOURCE,UUID,TARGET,FSTYPE,OPTIONS,FSROOT \
    | grep -v -e "ro," -e "fuse." -e "gocryptfs" -e "sshfs" -e "/run/media" | sed "s/$/ _/g")
    
else if [ $(findmnt --real --raw | grep '/mnt ' | wc -l) -gt 0 ]; then
  fstab=$(findmnt --noheadings --real --raw --uniq --nofsroot --output SOURCE,UUID,TARGET,FSTYPE,OPTIONS,FSROOT \
    | grep -v -e "ro," -e "fuse." -e "gocryptfs" -e "sshfs" -e "/run/media" | sed "s/$/ _/g" | sed "s/\/mnt/\//g")
fi
fi

oldIFS=$IFS
IFS="_"

for entry in $fstab
do
    mountpoint=$(echo "$entry" | awk -F ' ' '{ print $3 }' | sed '/^\//! s/^//g' | tr -d '\n')
    case "$mountpoint" in "") continue ;; esac

    device="/dev/disk/by-uuid/$(echo "$entry" | awk -F ' ' '{ print $2 }' | tr -d '\n')"
    filesystem=$(echo "$entry" | awk -F ' ' '{ print $4 }' | tr -d '\n')
    options=$(echo "$entry" | awk -F ' ' '{ print $5 }' | tr -d '\n')


    # Determine whether it is a mount-bind or not (via fsroot)
    # And mount it correctly (via source)
    source=$(echo "$entry" | awk -F ' ' '{ print $1 }' | tr -d '\n')
    fsroot=$(echo "$entry" | awk -F ' ' '{ print $6 }' | tr -d '\n')

    if [ "$fsroot" != "/" ]
    then
        partMountpoint=$(findmnt --raw --noheadings "$source" --output TARGET,SOURCE | grep -v "\[" | awk -F ' ' '{ print $1 }')

        device="$partMountpoint$fsroot"
        filesystem="none"
        options="bind"
    fi

    echo "    \"$mountpoint\" = {
          device = \"$device\";
          fsType = \"$filesystem\";
          options = [ \"$options\" ];
        };
        " >> "$hardwarefile"
done

IFS=$oldIFS


# End of filesystems

echo "  };
" >> "$hardwarefile"


# First lines

echo "

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CRYPTTAB
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  environment.etc.crypttab = {
    enable = true;
    text = ''" >> "$hardwarefile"

# Rebuild of actually USED luks encrypted partitions
luksDevices=$(lsblk --fs --noheadings --filter 'MOUNTPOINTS =~ "/" AND NAME =~ "luks-"' --output 'NAME' | sed "s/$/ _/g")

oldIFS=$IFS
IFS="_"

for entry in $luksDevices
do
    plain=$(echo "$entry" | awk -F ' ' '{ print $1 }' | tr -d '\n')
    cipher="/dev/disk/by-uuid/$(echo "$entry" | awk -F ' ' '{ print $1 }' | tr -d '\n' | sed 's/luks-//g')"

    echo "      $plain $cipher /etc/keys/keyfile.key luks" >> "$hardwarefile"

done

IFS=$oldIFS

# End of crypttab

echo "    '';
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROOT DISK ENCRYPTION
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" >> "$hardwarefile"



# First step : determine whether root disk is encrypted
root=$(lsblk --raw --output NAME,FSTYPE,MOUNTPOINT | rev | grep '^/' | rev)

if [ "$(echo $root | awk -F '-' '{ print $1}')" = "luks" ]
then

  plain=$(echo "$root" | awk -F ' ' '{ print $1 }' | tr -d '\n')
  cipher="/dev/disk/by-uuid/$(echo "$root" | awk -F ' ' '{ print $1 }' | tr -d '\n' | sed 's/luks-//g')"

  # Remove entry from crypttab
  sed -i "/$plain/d" "$hardwarefile"

  # Add fullencryption
  echo "  boot.initrd = {

    luks.devices.\"$plain\" = {
      device = \"$cipher\";
      allowDiscards = true;
      preLVM = true;
      keyFile = \"/keyfile1.bin\";
    };

    secrets = {
      \"keyfile1.bin\" = \"/etc/keys/keyfile.key\";
    };

  };
  " >> "$hardwarefile"

fi

echo "

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # OTHER HARDWARE AUTOMATIONS
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" >> "$hardwarefile"

# UEFI mountpoint (/boot/efi; /efi; other)
mountpoint=$(findmnt --noheadings --raw --real --uniq --nofsroot --output TARGET | grep -e "efi")
echo "  boot.loader.efi.efiSysMountPoint = \"$mountpoint\";
" >> "$hardwarefile"


# Ethernet specific driver
if [ $(lspci | grep Ethernet | grep RTL8125 | wc -l) -gt 0 ]
then
  echo "  mle.hardware.rtl8125.enable = true;
  " >> "$hardwarefile"
fi


# CPU Intel/AMD microcode and firmware
brand=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F ':' '{ print $2 }' | awk -F ' ' '{ print $1 }' | tr -d ' ')

if [ "$brand" = "amd" ] || [ "$brand" = "AMD" ]

then
  echo "  mle.hardware.amdcpu.enable = true;
  " >> "$hardwarefile"

elif [ "$brand" = "intel" ] || [ "$brand" = "INTEL" ] || [ "$brand" = "Intel" ]
then
  echo "  mle.hardware.intelcpu.enable = true;
  " >> "$hardwarefile"
fi


# Swapfile
ramsize=$(($(cat /proc/meminfo | grep MemTotal | awk -F ' ' '{ print $2 }') / 1024 ))
echo "  swapDevices = [{
    device = \"/var/media/data1/swapfile\";
    size = $ramsize;
  }];
  " >> "$hardwarefile"


# End of file

echo "
}
" >> "$hardwarefile"
