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

cryptpart=$(lsblk --raw | grep crypt | awk -F ' ' '{ print $1 }')
cryptsetup close /dev/mapper/"$cryptpart"


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
# Clone github repo
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos

git clone https://github.com/matleborgne/mle-nixos
mv mle-nixos github

mkdir -p build
bash github/scripts/github-autosync.sh
cp -r github/secrets build/secrets
