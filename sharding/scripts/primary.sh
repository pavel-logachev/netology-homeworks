#!/usr/bin/env bash
set -euo pipefail
# Added after schema creation; only this lab network reaches the server.
printf '\nhost replication replicator all trust\n' >> "$PGDATA/pg_hba.conf"
