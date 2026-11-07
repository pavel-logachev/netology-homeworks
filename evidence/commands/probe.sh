#!/bin/bash
exec 2>&1
echo '=== kernel ==='
uname -a
echo '=== filesystems ==='
cat /proc/filesystems
echo '=== crypto ==='
head -60 /proc/crypto
echo '=== install probe tools ==='
apt-get update -qq && apt-get install -y -qq kmod dmsetup
echo '=== modprobe ecryptfs ==='
modprobe ecryptfs
echo '=== modprobe dm_crypt ==='
modprobe dm_crypt
echo '=== dmsetup targets ==='
dmsetup targets
echo '=== filesystems after modules ==='
cat /proc/filesystems
