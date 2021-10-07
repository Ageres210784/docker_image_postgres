FROM postgres:12.8

RUN apt update -y && \
    apt install -y wget && \
    wget https://github.com/wal-g/wal-g/releases/download/v1.1/wal-g-pg-ubuntu-20.04-amd64 && \
    chmod +x wal-g-pg-ubuntu-20.04-amd64 && \
	  mv wal-g-pg-ubuntu-20.04-amd64 /usr/bin/wal-g && \
    wget https://github.com/hairyhenderson/gomplate/releases/download/v3.10.0/gomplate_linux-amd64 && \
    chmod +x gomplate_linux-amd64 && \
		mv gomplate_linux-amd64 /usr/bin/gomplate && \
		mkdir -p /etc/postgresql/ && \
    cp /usr/share/postgresql/postgresql.conf.sample /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_mode = off/archive_mode = {{.Env.ARCHIVE_MODE}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_timeout = 0/archive_timeout = {{.Env.ARCHIVE_TIMEOUT}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_command = ''/archive_command = 'wal-g wal-push %p'/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#restore_command = ''/restore_command = 'wal-g wal-fetch %f %p'/" /etc/postgresql/postgresql.conf.tmpl
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# See environment variables documentation https://github.com/wal-g/wal-g/blob/master/PostgreSQL.md#configuration
ENV ARCHIVE_MODE=off
ENV ARCHIVE_TIMEOUT=0

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
