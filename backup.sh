#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

if [[ -e .env ]]; then
  # shellcheck disable=SC1091
  . .env
fi

if [[ -z "${MYSQL_ROOT_PASSWORD:-}" || -z "${MYSQL_DATABASE:-}" ]]; then
  echo_error 'Required environment variable not defined.'
  exit 1
fi

BACKUP_DIR="$SCRIPT_DIR/backup/$(date +%Y%m%d%H%M%S)"
readonly BACKUP_DIR
mkdir -p "$BACKUP_DIR"
CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE
$CONTAINER_ENGINE exec bbs-db sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqldump --databases $MYSQL_DATABASE --user=root" \
  | gzip >"$BACKUP_DIR"/mysql.sql.gz
./tools/docker-compose-wrapper.sh logs | gzip >"$BACKUP_DIR"/containers.log.gz
