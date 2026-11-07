#!/bin/bash
exec 2>&1
set -x
ls -ld /home/cryptouser /home/.ecryptfs/cryptouser/.Private
findmnt -t ecryptfs
keyctl show
journalctl -k -n 35 --no-pager
zcat /usr/share/man/man7/ecryptfs.7.gz | grep -A5 -B2 -E 'fnek|filename|sig|unlink'
zcat /usr/share/man/man8/mount.ecryptfs.8.gz | head -100
