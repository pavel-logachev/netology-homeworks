#!/usr/bin/env bash
# Repeat only against disposable target server id 109; not the source.
set -Eeuo pipefail
set -x
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT @@hostname,@@server_id; DROP DATABASE demo;'
mysql --defaults-extra-file=/root/target.cnf -e 'source /backups/full.sql'
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT count(*) AS full_rows,sum(amount) AS total FROM demo.payments;'
mysqlbinlog --start-position=157 /backups/incremental/binlog.000005 | mysql --defaults-extra-file=/root/target.cnf --binary-mode
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT * FROM demo.payments ORDER BY id; SELECT count(*) AS recovered_rows,sum(amount) AS total FROM demo.payments;'
mysql --defaults-extra-file=/root/target.cnf -NB -e 'SELECT c.id,c.name,p.id,p.amount FROM demo.customers c JOIN demo.payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/restored-summary.tsv
test "$(sha256sum /backups/expected.tsv | cut -d ' ' -f1)" = "$(sha256sum /backups/restored-summary.tsv | cut -d ' ' -f1)"
echo 'PASS: full + binlog = exact source rows (4 payments, 2650.50)'
