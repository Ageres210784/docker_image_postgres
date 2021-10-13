# postgresql_with_wal-g

This progect to install the wal-g in a postgresql container.

The container is configured at startup using environment variables. For more information about variables see <https://hub.docker.com/_/postgres> and <https://github.com/wal-g/wal-g>

The variable `ARCHIVE_MODE` enables archiving wal if it set in "`on`"

For example see the `docker-compose.yml.example` and `.env.example`

## Sequencing

- change the versions of the postgres container and wal-g in the Dockerfile
- change container name and other parameters in docker-compose.yml
- docker-compose build
- docker-compose up -d
- for periodic archiving, you need to configure the cron with the following task:

```bash
0 2 * * * /usr/local/bin/wal-g backup-push /var/lib/postgresql/12/main >> /var/log/postgresql/walg_backup.log 2>&1
````
- to clean up archives:

```bash
0 1 * * * /usr/local/bin/wal-g delete before FIND_FULL $(date -d '-1 days' '+\%FT\%TZ') --confirm >> /var/log/postgresql/walg_delete.log 2>&1
```