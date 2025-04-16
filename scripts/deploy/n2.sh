#!/bin/bash

set -x
PATH=$PATH:/run/current-system/sw/bin

echo "Enter disk path (ex: /dev/sda, /dev/nvme0n1, etc.) :"
read disk

echo "Enter desired password for luks :"
stty -echo
read $password
stty echo

if [[ "$disk" == *"nvme"* ]]; then
  parts="$disk"p
else
  parts="$disk"
fi


umount -Rl /mnt

uncryptpart=$(lsblk --raw | grep crypt | awk -F ' ' '{ print $1 }')
cryptsetup close /dev/mapper/"$uncryptpart"

cryptpart=$(lsblk --raw -o NAME,FSTYPE | grep LUKS | awk -F ' ' '{ print $1 }')
cryptsetup luksErase /dev/"$cryptpart"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Partition table and parts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sgdisk -Z "$disk"

sgdisk \
  --new=1:0:+256M \
  --typecode=1:ef00 \
  --change-name=1:efi \
  "$disk"

sgdisk \
  --new=2:0:+1G \
  --typecode=2:8300 \
  --change-name=2:boot \
  "$disk"

sgdisk \
  --largest-new=3 \
  --typecode=3:8304 \
  --change-name=3:root \
  "$disk"

partprobe -s "$disk"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Filesystems
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# LUKS root
echo -e "$password\n$password" | cryptsetup luksFormat "$parts"3

rootid=$(blkid -o value -s UUID "$parts"3)
rootmap="luks-$rootid"

echo -e "$password" | cryptsetup open "$parts"3 "$rootmap"
unset password


# Filesystems
mkfs.ext4 -F /dev/mapper/"$rootmap"
mkfs.ext4 -F "$parts"2
mkfs.vfat -F32 "$parts"1


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mounting
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mount --mkdir -o "rw,noatime" /dev/mapper/"$rootmap" /mnt
mount --mkdir -o "rw,noatime" "$parts"2 /mnt/boot
mount --mkdir -o "rw,noatime" "$parts"1 /mnt/efi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare /etc/nixos
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos

# Clone and rename github repo
git clone https://github.com/matleborgne/mle-nixos
mv mle-nixos github

# Sync github files with build for first build
mkdir -p build/secrets
bash github/scripts/github-autosync.sh

# Calculate hardware and include in imports
bash build/scripts/hardware-configuration.sh
bash build/scripts/mlemodules.sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Deploy nixos
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nixos-install --flake /mnt/etc/nixos/build#n2
