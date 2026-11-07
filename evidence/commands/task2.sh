#!/bin/bash
set -euo pipefail
exec 2>&1
export LC_ALL=C
set -x
truncate -s 100M /var/tmp/nt1302-luks.img
loop=$(losetup --find --show /var/tmp/nt1302-luks.img)
losetup -l "$loop"
blockdev --getsize64 "$loop"
set +x
umask 077
head -c 32 /dev/urandom > /run/nt1302-luks-key
# Random throwaway test key. Its contents are never printed.
set -x
cryptsetup luksFormat --type luks2 --batch-mode --key-file /run/nt1302-luks-key "$loop"
cryptsetup luksDump "$loop"
cryptsetup luksOpen --key-file /run/nt1302-luks-key "$loop" nt1302-crypt
cryptsetup status nt1302-crypt
mkfs.ext4 -L nt1302-data /dev/mapper/nt1302-crypt
mkdir -p /mnt/nt1302-luks
mount /dev/mapper/nt1302-crypt /mnt/nt1302-luks
printf 'LUKS encrypted volume, Netology practical.\n' > /mnt/nt1302-luks/document.txt
cat /mnt/nt1302-luks/document.txt
sha256sum /mnt/nt1302-luks/document.txt > /run/nt1302-luks-sha
cat /run/nt1302-luks-sha
findmnt /mnt/nt1302-luks
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS "$loop"
sync
umount /mnt/nt1302-luks
cryptsetup luksClose nt1302-crypt
if cryptsetup status nt1302-crypt; then echo 'FAIL: mapping still active'; exit 1; else echo 'PASS: LUKS mapping inactive after close'; fi
if grep -aF 'LUKS encrypted volume, Netology practical.' /var/tmp/nt1302-luks.img; then echo 'FAIL: plaintext found in backing image'; exit 1; else echo 'PASS: plaintext absent from backing image'; fi
cryptsetup luksOpen --key-file /run/nt1302-luks-key "$loop" nt1302-crypt
mount /dev/mapper/nt1302-crypt /mnt/nt1302-luks
sha256sum --check /run/nt1302-luks-sha
cat /mnt/nt1302-luks/document.txt
umount /mnt/nt1302-luks
cryptsetup luksClose nt1302-crypt
losetup -d "$loop"
losetup -j /var/tmp/nt1302-luks.img
rm -f /run/nt1302-luks-key /run/nt1302-luks-sha /var/tmp/nt1302-luks.img
rmdir /mnt/nt1302-luks
echo 'PASS: reopen checksum verified; mapping closed; loop detached; temporary key and image removed'
