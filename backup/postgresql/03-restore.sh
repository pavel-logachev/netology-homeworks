#!/usr/bin/env bash
# Destructive rehearsal: disposable demo database in nt-bkp-pg ONLY.
set -Eeuo pipefail
set -x
dropdb demo
createdb -T template0 demo
pg_restore --exit-on-error -d demo /backups/demo.dump
psql -X -At -d demo -c 'SELECT c.id,c.name,p.id,p.amount FROM customers c JOIN payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/after.tsv
diff -u /backups/before.tsv /backups/after.tsv
psql -X -d demo -v ON_ERROR_STOP=1 <<'SQL'
SELECT * FROM customers ORDER BY id;
SELECT * FROM payments ORDER BY id;
SELECT count(*) AS payments, sum(amount) AS total FROM payments;
SELECT conname, contype, convalidated FROM pg_constraint WHERE conrelid IN ('customers'::regclass,'payments'::regclass) ORDER BY conname;
SELECT tablename,indexname FROM pg_indexes WHERE schemaname='public' ORDER BY indexname;
SELECT relname,pg_get_userbyid(relowner) AS owner FROM pg_class WHERE relname IN ('customers','payments');
SELECT last_value,is_called FROM customers_id_seq;
SELECT last_value,is_called FROM payments_id_seq;
SQL
printf 'PASS: exact ordered rows, counts, totals, constraints, indexes, owners and sequences checked\n'
