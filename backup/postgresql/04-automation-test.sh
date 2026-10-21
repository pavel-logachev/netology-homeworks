#!/usr/bin/env bash
set -Eeuo pipefail
set -x
mkdir -p /backups/daily
touch -d '10 days ago' /backups/daily/demo_retention_fixture.dump
touch /backups/daily/demo_recent_fixture.dump
bash /lab/backup.sh
test ! -e /backups/daily/demo_retention_fixture.dump
test -e /backups/daily/demo_recent_fixture.dump
latest=$(find /backups/daily -name 'demo_20*.dump' -type f | sort | tail -n 1)
createdb demo_auto
pg_restore --exit-on-error -d demo_auto "$latest"
psql -X -At -d demo_auto -c 'SELECT c.id,c.name,p.id,p.amount FROM customers c JOIN payments p ON p.customer_id=c.id ORDER BY p.id' > /backups/auto.tsv
diff -u /backups/before.tsv /backups/auto.tsv
psql -X -d demo_auto -c 'SELECT count(*) AS payments, sum(amount) AS total FROM payments;'
printf 'PASS: automation dump restored; old fixture deleted, recent fixture retained\n'
