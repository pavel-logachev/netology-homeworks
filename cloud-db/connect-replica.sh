#!/bin/sh
set -eu
# Obtain replica FQDN using yc managed-postgresql hosts list --cluster-name nt-1209-pg.
: "${PGPASSWORD:?Set PGPASSWORD securely}"
: "${PGREPLICA:?Set only the replica host FQDN}"
unset PGTARGETSESSIONATTRS
export PGCLIENTENCODING=UTF8
exec psql -X -a "host=$PGREPLICA port=6432 sslmode=verify-full dbname=nt-1209-db user=nt-1209-user connect_timeout=15" -f /work/sql/replica.sql
