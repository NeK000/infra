#!/usr/bin/env bash
set -euo pipefail

interval="${PGBACKREST_FULL_BACKUP_INTERVAL_SECONDS:-86400}"

until pg_isready -h 127.0.0.1 -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" >/dev/null 2>&1; do
  sleep 5
done

pgbackrest --stanza=main stanza-create || true
pgbackrest --stanza=main check || true
pgbackrest --stanza=main --type=full backup || true

while true; do
  sleep "${interval}"
  pgbackrest --stanza=main backup || true
done
