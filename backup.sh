#!/bin/bash
set -Eeu -o pipefail

if [[ -e .env ]]; then
  # shellcheck disable=SC1091
  . .env
fi

if [[ -z "${MYSQL_ROOT_PASSWORD:-}" || -z "${MYSQL_DATABASE:-}" ]]; then
  echo "Required environment variable not defined."
  exit 1
fi

BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)/backup/$(date +%Y%m%d%H%M%S)"
readonly BACKUP_DIR
mkdir -p "$BACKUP_DIR"
DOCKER=$(command -v docker || command -v podman)
readonly DOCKER
$DOCKER exec bbs-db sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqldump --databases $MYSQL_DATABASE --user=root" \
  | gzip >"$BACKUP_DIR"/mysql.sql.gz
./tools/docker-compose-wrapper.sh logs | gzip >"$BACKUP_DIR"/containers.log.gz
