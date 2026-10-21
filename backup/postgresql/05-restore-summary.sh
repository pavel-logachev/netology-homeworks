#!/usr/bin/env bash
# Compact real restore rehearsal for screenshot; details in 03-restore.sh/log.
set -Eeuo pipefail
set -x
dropdb demo
createdb -T template0 demo
pg_restore --exit-on-error -d demo /backups/demo.dump
psql -X -d demo -v ON_ERROR_STOP=1 -c 'SELECT * FROM customers ORDER BY id; SELECT * FROM payments ORDER BY id; SELECT count(*) AS payments,sum(amount) AS total FROM payments;'
psql -X -At -d demo -c 'SELECT c.id,c.name,p.id,p.amount FROM customers c JOIN payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/after.tsv
diff -u /backups/before.tsv /backups/after.tsv
echo 'PASS: restored rows exactly match the pre-backup query'
