#!/usr/bin/env bash
# Run inside nt-bkp-pg as postgres (or PGUSER=postgres); no password in script.
set -Eeuo pipefail
umask 077
export PATH=/usr/local/bin:/usr/bin:/bin
export PGUSER="${PGUSER:-postgres}"
BACKUP_DIR=/backups/daily
RETENTION_DAYS=7
mkdir -p "$BACKUP_DIR"
# Prevent overlapping jobs; trap clears only this script's lock.
if ! mkdir "$BACKUP_DIR/.backup-lock" 2>/dev/null; then
  echo 'Backup already running (or stale lock: inspect before removal)' >&2
  exit 1
fi
stamp=$(date -u +%Y%m%dT%H%M%S_%NZ)
final="$BACKUP_DIR/demo_${stamp}.dump"
tmp="${final}.partial"
trap 'rm -f -- "$tmp"; rmdir "$BACKUP_DIR/.backup-lock"' EXIT
pg_dump -Fc -d demo -f "$tmp"
pg_restore --list "$tmp" >/dev/null
mv -- "$tmp" "$final"
# GNU find rounds age down to whole days; +7 means >=8*24 hours, not exactly 7 days.
find "$BACKUP_DIR" -maxdepth 1 -type f -name 'demo_*.dump' -mtime +"$RETENTION_DAYS" -print -delete
printf 'Created %s\n' "$final"
ls -lh "$final"
sha256sum "$final"
