#!/bin/bash
set -eu -o pipefail

if [[ -e .env ]]; then
  # shellcheck disable=SC1091
  . .env
fi

if [[ -z "${MYSQL_ROOT_PASSWORD:-}" || -z "${MYSQL_USER:-}" || -z "${MYSQL_PASSWORD:-}" || -z "${MYSQL_DATABASE:-}" ]]; then
  echo "Required environment variable not defined."
  exit 1
fi

./tools/docker-compose-wrapper.sh up -d db
DOCKER=$(command -v docker || command -v podman)
readonly DOCKER
$DOCKER exec -it bbs-db mysql --host bbs-db --default-character-set=utf8mb4 --port 3306 -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}"
