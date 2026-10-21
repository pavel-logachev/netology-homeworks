#!/usr/bin/env bash
set -Eeuo pipefail
set -x
start_file=$(< /backups/start-file.txt)
current_file=$(mysql --defaults-extra-file=/root/source.cnf -NBe 'SHOW MASTER STATUS' | cut -f1)
# This lab generates one closed increment; a real job copies ALL closed logs in the range.
test "$current_file" = "$start_file"
mysql --defaults-extra-file=/root/source.cnf -t <<'SQL'
USE demo;
START TRANSACTION;
INSERT INTO customers(name) VALUES('Boris');
INSERT INTO payments(customer_id,amount) VALUES(1,100.00),(3,500.00);
UPDATE payments SET amount=800.50 WHERE id=2;
COMMIT;
SELECT * FROM payments ORDER BY id;
SELECT count(*) AS payments,sum(amount) AS total FROM payments;
FLUSH BINARY LOGS;
SHOW BINARY LOGS;
SQL
# The rotated file is closed: do not copy the active last file.
cp "/var/lib/mysql/$start_file" /backups/incremental/
ls -lh /backups/incremental/
sha256sum "/backups/incremental/$start_file"
mysql --defaults-extra-file=/root/source.cnf -NB -e 'SELECT c.id,c.name,p.id,p.amount FROM demo.customers c JOIN demo.payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/expected.tsv
