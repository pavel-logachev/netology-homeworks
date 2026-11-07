#!/bin/bash
set -euo pipefail
exec 2>&1
set -x
date -u --iso-8601=seconds
uname -r
findmnt -t ecryptfs || true
test ! -e /dev/mapper/nt1302-crypt
! losetup -a | grep nt1302
! find /run -maxdepth 1 -name 'nt1302-*' | grep .
! grep nt1302-reader /sys/kernel/security/apparmor/profiles
systemctl is-active apparmor || true
dpkg-query -W ecryptfs-utils cryptsetup
echo 'PASS: no mounted eCryptfs home, LUKS mapping, owned loop, temporary passphrase/key, or demo AppArmor profile remains'
