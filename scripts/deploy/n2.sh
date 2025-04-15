#!/bin/bash

set -x
PATH=$PATH:/run/current-system/sw/bin

disk="/dev/sda"

umount -Rl /mnt

cryptpart=$(lsblk --raw | grep crypt | awk -F ' ' '{ print $1 }')
cryptsetup close /dev/mapper/"$cryptpart"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Partition table and parts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sgdisk -Z /dev/sda

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
cryptsetup luksFormat "$disk"3

rootid=$(blkid -o value -s UUID "$disk"3)
rootmap="luks-$rootid"

cryptsetup open "$disk"3 "$rootmap"


# Filesystems
mkfs.ext4 -F /dev/mapper/"$rootmap"
mkfs.ext4 -F "$disk"2
mkfs.vfat -F32 "$disk"1


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mounting
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mount --mkdir -o "rw,noatime" /dev/mapper/"$rootmap" /mnt
mount --mkdir -o "rw,noatime" "$disk"2 /mnt/boot
mount --mkdir -o "rw,noatime" "$disk"1 /mnt/efi
