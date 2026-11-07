#!/bin/bash
set -euo pipefail
mkdir -p /run/sshd /var/run/fail2ban /var/log/suricata /var/lib/suricata/rules
# Synthetic disposable credentials, never reused outside this isolated lab.
id labuser >/dev/null 2>&1 || useradd -m -s /bin/bash labuser
echo 'labuser:LabOnly-1303-Throwaway!' | chpasswd
ssh-keygen -A
cp /lab/sshd_config /etc/ssh/sshd_config
cp /lab/jail.local /etc/fail2ban/jail.local
touch /var/log/auth.log /var/log/fail2ban.log
printf 'module(load="imuxsock")\nauth,authpriv.* /var/log/auth.log\n' > /etc/rsyslog.conf
rsyslogd
/usr/sbin/sshd
# ET Open was downloaded during the image build; the runtime network has no external access.
cp /lab/local.rules /var/lib/suricata/rules/local.rules
fail2ban-server -b
exec sleep infinity
