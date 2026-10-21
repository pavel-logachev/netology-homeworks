#!/usr/bin/env bash
set -euo pipefail
for key in a b; do
  primary="nt-shard-users-$key"
  replica="nt-shard-replica-$key"
  lsn=$(psql -XAt -h "$primary" -c 'SELECT pg_current_wal_lsn()')
  ready=false
  for attempt in {1..60}; do
    result=$(psql -XAt -h "$replica" -c "SELECT pg_is_in_recovery() AND pg_last_wal_replay_lsn() >= '$lsn'::pg_lsn")
    if [ "$result" = t ]; then ready=true; break; fi
    sleep 1
  done
  [ "$ready" = true ] || { echo "FAIL: $replica replay timeout"; exit 1; }
  echo "PASS: $replica replayed primary WAL through $lsn"
done
