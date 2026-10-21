#!/usr/bin/env bash
# Fresh nt-bkp-mysql-restore, not the source. DB keeps the name demo (ROW binlogs).
set -Eeuo pipefail
set -x
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT @@hostname,@@server_id;'
test "$(mysql --defaults-extra-file=/root/target.cnf -NBe "SELECT count(*) FROM information_schema.schemata WHERE schema_name='demo'")" = 0
mysql --defaults-extra-file=/root/target.cnf < /backups/full.sql
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT count(*) AS full_only_rows,sum(amount) AS full_only_total FROM demo.payments;'
test "$(mysql --defaults-extra-file=/root/target.cnf -NBe 'SELECT count(*) FROM demo.payments')" = 2
start_file=$(< /backups/start-file.txt)
start_pos=$(< /backups/start-position.txt)
mysqlbinlog --start-position="$start_pos" "/backups/incremental/$start_file" | mysql --defaults-extra-file=/root/target.cnf --binary-mode
mysql --defaults-extra-file=/root/target.cnf -t -e 'SELECT * FROM demo.customers ORDER BY id; SELECT * FROM demo.payments ORDER BY id; SELECT count(*) AS restored_rows,sum(amount) AS restored_total FROM demo.payments;'
mysql --defaults-extra-file=/root/target.cnf -NB -e 'SELECT c.id,c.name,p.id,p.amount FROM demo.customers c JOIN demo.payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/restored.tsv
test "$(sha256sum /backups/expected.tsv | cut -d ' ' -f1)" = "$(sha256sum /backups/restored.tsv | cut -d ' ' -f1)"
test "$(mysql --defaults-extra-file=/root/target.cnf -NBe 'SELECT CONCAT(count(*),CHAR(58),sum(amount)) FROM demo.payments')" = '4:2650.50'
echo 'PASS: full backup = 2 payments; binlog replay = 4 payments, total 2650.50; exact rows match source'
