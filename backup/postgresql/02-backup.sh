#!/usr/bin/env bash
set -Eeuo pipefail
set -x
pg_dump -Fc -d demo -f /backups/demo.dump
pg_dumpall --globals-only --no-role-passwords -f /backups/globals.sql
ls -lh /backups/demo.dump /backups/globals.sql
sha256sum /backups/demo.dump /backups/globals.sql
pg_restore --list /backups/demo.dump | tail -n 12
