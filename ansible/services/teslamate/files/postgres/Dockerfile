ARG PG_MAJOR=18
FROM postgres:${PG_MAJOR}

RUN apt-get update \
 && apt-get install -y --no-install-recommends pgbackrest \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/teslamate-postgres-entrypoint.sh
COPY backup-loop.sh /usr/local/bin/teslamate-pgbackrest-loop.sh

RUN chmod +x /usr/local/bin/teslamate-postgres-entrypoint.sh /usr/local/bin/teslamate-pgbackrest-loop.sh

ENTRYPOINT ["teslamate-postgres-entrypoint.sh"]
CMD ["postgres"]
