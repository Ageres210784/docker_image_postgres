#!/bin/bash
set -e

gomplate -f /etc/postgresql/postgresql.conf.tmpl -o /etc/postgresql/postgresql.conf

if [[ $RECOVERY_WALG = "true" ]]
  then rm -rf $PGDATA/*
  wal-g backup-fetch $PGDATA $WALG_RESTORE_NAME
  touch $PGDATA/recovery.signal
  chown -R postgres: $PGDATA
fi

/usr/local/bin/docker-entrypoint.sh "$@"