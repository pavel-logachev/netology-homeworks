#!/bin/sh
set -eu
# Run inside the psql helper with the downloaded CA at /work/root.crt.
# PGPASSWORD is inherited securely, never passed as an argument.
: "${PGPASSWORD:?Set PGPASSWORD securely}"
: "${PGHOSTS:?Set both host FQDNs separated by a comma}"
: "${PGSSLROOTCERT:=/work/root.crt}"
export PGSSLROOTCERT PGCLIENTENCODING=UTF8
exec psql -X -a "host=$PGHOSTS port=6432 sslmode=verify-full dbname=nt-1209-db user=nt-1209-user target_session_attrs=read-write connect_timeout=15" -f /work/sql/master.sql
