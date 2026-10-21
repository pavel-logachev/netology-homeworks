#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  # Empty dedicated volume only. Never erase or reinitialize existing database data.
  gosu postgres pg_basebackup -h "$PRIMARY_HOST" -U replicator -D "$PGDATA" \
    -Fp -Xs -P -R -C -S "$REPLICA_SLOT" -d "application_name=$REPLICA_SLOT connect_timeout=10"
fi
exec gosu postgres postgres -D "$PGDATA" -c hot_standby=on
