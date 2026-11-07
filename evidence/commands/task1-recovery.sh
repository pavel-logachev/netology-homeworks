#!/bin/bash
set -euo pipefail
exec 2>&1
export LC_ALL=C
set -x
keyctl link @u @s
# Keep insertion in the current shell's keyring, not a command-substitution subshell.
set +x
ecryptfs-add-passphrase --fnek < /run/nt1302-ecryptfs-pass > /run/nt1302-key-signatures
cat /run/nt1302-key-signatures
mapfile -t sigs < <(sed -n 's/.*\[\([0-9a-f]*\)\].*/\1/p' /run/nt1302-key-signatures)
test "${#sigs[@]}" -eq 2
opts="ecryptfs_sig=${sigs[0]},ecryptfs_fnek_sig=${sigs[1]},ecryptfs_cipher=aes,ecryptfs_key_bytes=16"
set -x
keyctl show
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
mount -i -t ecryptfs /home/.ecryptfs/cryptouser/.Private /home/cryptouser -o "$opts"
sudo -u cryptouser cat /home/cryptouser/document.txt
cmp /root/nt1302-home-original/document.txt /home/cryptouser/document.txt
echo 'PASS: remount restores the original document exactly'
umount /home/cryptouser
rm -rf /root/nt1302-home-original
rm -f /run/nt1302-ecryptfs-pass /run/nt1302-key-signatures
echo 'PASS: eCryptfs home unmounted; temporary passphrase and original backup removed'
