#!/bin/bash
/usr/bin/wal-g "$@"
BACKUP_RESULT=$?

send_notification() {
  if [ -n "${APPRISE_TARGET}" ]; then
    apprise -t "Failed to create wal-g backup" -b "${1}" "${APPRISE_TARGET}"
  fi
}

if [ "${BACKUP_RESULT}" -ne 0 ]; then
  send_notification "Error to create backup to «${WALG_S3_PREFIX}» bucket with code ${BACKUP_RESULT}"
fi
