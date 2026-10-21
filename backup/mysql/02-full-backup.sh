#!/usr/bin/env bash
set -Eeuo pipefail
set -x
mysqldump --defaults-extra-file=/root/source.cnf --single-transaction --source-data=2 --flush-logs --set-gtid-purged=OFF --databases demo > /backups/full.sql
# Record exactly the recovery coordinate embedded by mysqldump.
# 8.0.46 accepts --source-data but emits legacy CHANGE MASTER coordinates.
sed -n '/^-- CHANGE .* TO /p' /backups/full.sql
sed -n "s/.*[A-Z]*_LOG_FILE='\([^']*\)'.*/\1/p" /backups/full.sql > /backups/start-file.txt
sed -n 's/.*[A-Z]*_LOG_POS=\([0-9]*\).*/\1/p' /backups/full.sql > /backups/start-position.txt
test -s /backups/start-file.txt
test -s /backups/start-position.txt
ls -lh /backups/full.sql
sha256sum /backups/full.sql
mysql --defaults-extra-file=/root/source.cnf -t -e 'SHOW MASTER STATUS; SELECT count(*) AS payments,sum(amount) AS total FROM demo.payments;'
