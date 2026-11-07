#!/bin/bash
set -euo pipefail
exec 2>&1
export LC_ALL=C
set -x
useradd --create-home --shell /bin/bash cryptouser
id cryptouser
sudo -u cryptouser bash -c 'printf "Netology host protection. Readable personal document.\n" > /home/cryptouser/document.txt; printf "Private project notes.\n" > /home/cryptouser/notes.txt'
ls -la /home/cryptouser
cat /home/cryptouser/document.txt /home/cryptouser/notes.txt
mv /home/cryptouser /root/nt1302-home-original
install -d -m 700 -o cryptouser -g cryptouser /home/cryptouser /home/.ecryptfs/cryptouser/.Private
set +x
umask 077
head -c 32 /dev/urandom | base64 > /run/nt1302-ecryptfs-pass
# Test passphrase used. Neither its value nor a wrapped copy is logged.
keys=$(ecryptfs-add-passphrase --fnek < /run/nt1302-ecryptfs-pass)
printf '%s\n' "$keys"
mapfile -t sigs < <(printf '%s\n' "$keys" | sed -n 's/.*\[\([0-9a-f]*\)\].*/\1/p')
test "${#sigs[@]}" -eq 2
opts="ecryptfs_sig=${sigs[0]},ecryptfs_fnek_sig=${sigs[1]},ecryptfs_cipher=aes,ecryptfs_key_bytes=16,ecryptfs_passthrough=n,ecryptfs_unlink_sigs"
set -x
mount -i -t ecryptfs /home/.ecryptfs/cryptouser/.Private /home/cryptouser -o "$opts"
cp -a /root/nt1302-home-original/. /home/cryptouser/
findmnt -T /home/cryptouser
sudo -u cryptouser ls -la /home/cryptouser
sudo -u cryptouser cat /home/cryptouser/document.txt /home/cryptouser/notes.txt
sha256sum /root/nt1302-home-original/document.txt /home/cryptouser/document.txt
ls -la /home/.ecryptfs/cryptouser/.Private
lowerfile=$(find /home/.ecryptfs/cryptouser/.Private -maxdepth 1 -type f | head -1)
file "$lowerfile"
od -Ax -tx1 -N 96 "$lowerfile"
if grep -aR -F 'Readable personal document' /home/.ecryptfs/cryptouser/.Private; then echo 'FAIL: plaintext found'; exit 1; else echo 'PASS: plaintext marker absent from encrypted lower files'; fi
umount /home/cryptouser
findmnt -t ecryptfs || true
ls -la /home/cryptouser
ls -1 /home/.ecryptfs/cryptouser/.Private
# ecryptfs_unlink_sigs removed keys on unmount. Re-add and mount to test recovery.
set +x
ecryptfs-add-passphrase --fnek < /run/nt1302-ecryptfs-pass
set -x
mount -i -t ecryptfs /home/.ecryptfs/cryptouser/.Private /home/cryptouser -o "$opts"
sudo -u cryptouser cat /home/cryptouser/document.txt
cmp /root/nt1302-home-original/document.txt /home/cryptouser/document.txt
echo 'PASS: remount restores the original document exactly'
umount /home/cryptouser
rm -rf /root/nt1302-home-original
rm -f /run/nt1302-ecryptfs-pass
echo 'PASS: eCryptfs home unmounted; temporary passphrase and original backup removed'
