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
    cp /usr/share/postgresql/postgresql.conf.sample /etc/postgresql/postgresql.conf.tmpl
RUN sed -ri "s/^#recovery_target_action = 'pause'/recovery_target_action = {{.Env.RECOVERY_TARGET_ACTION}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#recovery_target_time = ''/recovery_target_time = {{.Env.RECOVERY_TARGET_TIME}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#recovery_target_timeline = 'latest'/recovery_target_timeline = {{.Env.RECOVERY_TARGET_TIMELINE}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_mode = off/archive_mode = {{.Env.ARCHIVE_MODE}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_timeout = 0/archive_timeout = {{.Env.ARCHIVE_TIMEOUT}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#archive_command = ''/archive_command = {{.Env.ARCHIVE_COMMAND}}/" /etc/postgresql/postgresql.conf.tmpl && \
    sed -ri "s/^#restore_command = ''/restore_command = {{.Env.RESTORE_COMMAND}}/" /etc/postgresql/postgresql.conf.tmpl
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# See environment variables documentation https://github.com/wal-g/wal-g/blob/master/PostgreSQL.md#configuration
ENV ARCHIVE_MODE=off
ENV ARCHIVE_TIMEOUT=0
ENV ARCHIVE_COMMAND="'wal-g wal-push %p'"
ENV RESTORE_COMMAND="'wal-g wal-fetch %f %p'"
ENV RECOVERY_TARGET_ACTION=\'pause\'
ENV RECOVERY_TARGET_TIME=\'\'
ENV RECOVERY_TARGET_TIMELINE=\'current\'
ENV RECOVERY_WALG=false
ENV WALG_RESTORE_NAME=LATEST
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
