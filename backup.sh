#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

if [[ -z "$($CONTAINER_ENGINE ps --filter "name=^bbs-db$" --filter "status=running" --quiet)" ]]; then
  echo_error 'bbs-db container is not running'
  exit 1
fi

BACKUP_DIR="$SCRIPT_DIR/backup/$(date +%Y%m%d%H%M%S)"
readonly BACKUP_DIR
mkdir -p "$BACKUP_DIR"

# shellcheck disable=SC2016
MYSQLDUMP_CMD='MYSQL_PWD="$(cat /run/secrets/mysql_root_password)" mysqldump --databases $MYSQL_DATABASE --user=root'
$CONTAINER_ENGINE exec bbs-db sh -c "$MYSQLDUMP_CMD" | gzip >"$BACKUP_DIR"/mysql.sql.gz
./tools/docker-compose-wrapper.sh logs | gzip >"$BACKUP_DIR"/containers.log.gz
