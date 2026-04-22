#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "postgres" ]; then
  mkdir -p /var/lib/pgbackrest /etc/pgbackrest
  chown -R postgres:postgres /var/lib/pgbackrest /var/lib/postgresql /var/run/postgresql || true
  /usr/local/bin/teslamate-pgbackrest-loop.sh &
fi

exec docker-entrypoint.sh "$@"
