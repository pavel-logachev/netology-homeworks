#!/bin/bash
set -euo pipefail
exec 2>&1
export LC_ALL=C
set -x
install -m 755 /bin/cat /usr/local/bin/nt1302-reader
printf 'AppArmor permitted document\n' > /var/tmp/nt1302-public.txt
printf 'AppArmor protected document\n' > /var/tmp/nt1302-secret.txt
/usr/local/bin/nt1302-reader /var/tmp/nt1302-secret.txt
cat > /etc/apparmor.d/nt1302-reader <<'PROFILE'
#include <tunables/global>
profile nt1302-reader /usr/local/bin/nt1302-reader {
  #include <abstractions/base>
  /usr/local/bin/nt1302-reader mr,
  /var/tmp/nt1302-public.txt r,
  audit deny /var/tmp/nt1302-secret.txt r,
}
PROFILE
cat /etc/apparmor.d/nt1302-reader
apparmor_parser -r /etc/apparmor.d/nt1302-reader
aa-status
/usr/local/bin/nt1302-reader /var/tmp/nt1302-public.txt
set +e
/usr/local/bin/nt1302-reader /var/tmp/nt1302-secret.txt
rc=$?
set -e
echo "Protected file read exit code: $rc"
test "$rc" -ne 0
journalctl -k --since '-2 minutes' --no-pager | grep 'apparmor="DENIED"' | grep nt1302
# Explicitly unload profiles, then stop the service and remove packages.
aa-teardown
systemctl stop apparmor
systemctl is-active apparmor || true
if grep -q nt1302-reader /sys/kernel/security/apparmor/profiles; then echo 'FAIL: demo profile still loaded'; exit 1; else echo 'PASS: demo profile unloaded'; fi
/usr/local/bin/nt1302-reader /var/tmp/nt1302-secret.txt
DEBIAN_FRONTEND=noninteractive apt-get purge -y apparmor apparmor-utils
if dpkg-query -W -f='${db:Status-Status}\n' apparmor 2>/dev/null | grep -qx installed; then echo 'FAIL: AppArmor package still installed'; exit 1; else echo 'PASS: AppArmor package removed'; fi
rm -f /etc/apparmor.d/nt1302-reader /usr/local/bin/nt1302-reader /var/tmp/nt1302-public.txt /var/tmp/nt1302-secret.txt
echo 'PASS: AppArmor enforce denial and audit verified; profiles unloaded; service stopped; userspace packages purged'
