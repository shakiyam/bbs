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

docker-compose up -d db
docker container run \
  -t \
  --name bbs_test \
  --net bbs_default \
  --rm \
  -e DB_USER="${MYSQL_USER}" \
  -e DB_PASSWORD="${MYSQL_PASSWORD}" \
  -e DB_HOST=db \
  -e DB_PORT=3306 \
  -e DB_DATABASE="${MYSQL_DATABASE}" \
  -u "$(id -u):$(id -g)" \
  shakiyam/bbs "$@"
