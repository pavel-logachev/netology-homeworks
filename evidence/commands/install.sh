#!/bin/bash
set -euo pipefail
exec 2>&1
export DEBIAN_FRONTEND=noninteractive
set -x
cloud-init status --wait
uname -a
cat /etc/os-release
apt-get update -qq
apt-get install -y ecryptfs-utils cryptsetup apparmor apparmor-utils keyutils
modprobe ecryptfs
modprobe dm_crypt
grep ecryptfs /proc/filesystems
dmsetup targets
dpkg-query -W ecryptfs-utils cryptsetup apparmor apparmor-utils
command -v ecryptfs-add-passphrase
zcat /usr/share/man/man8/mount.ecryptfs.8.gz | grep -A5 -B2 'sig_cache\|unlink_sigs'
