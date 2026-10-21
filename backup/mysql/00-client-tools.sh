#!/usr/bin/env bash
# mysql:8.0 minimal 8.0.46 lacks mysqlbinlog. Run only in disposable lab container.
# Official MySQL RPM; extract one client binary without replacing the server package.
set -Eeuo pipefail
curl --fail --location --connect-timeout 15 --max-time 90 \
  https://repo.mysql.com/yum/mysql-8.0-community/el/9/x86_64/mysql-community-client-8.0.46-1.el9.x86_64.rpm \
  -o /tmp/mysql-client.rpm
timeout 120 microdnf --disablerepo=mysql-tools-community --disablerepo=mysql8.0-server-minimal install -y cpio
mkdir -p /opt/mysql-client
cd /opt/mysql-client
rpm2cpio /tmp/mysql-client.rpm | cpio -id ./usr/bin/mysqlbinlog
ln -s /opt/mysql-client/usr/bin/mysqlbinlog /usr/local/bin/mysqlbinlog
mysqlbinlog --version
