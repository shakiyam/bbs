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
./tools/build.sh shakiyam/bbs
docker container run \
  --name bbs_development \
  --net bbs_default \
  --rm \
  -e DB_DATABASE="${MYSQL_DATABASE}" \
  -e DB_HOST=db \
  -e DB_PASSWORD="${MYSQL_PASSWORD}" \
  -e DB_PORT=3306 \
  -e DB_USER="${MYSQL_USER}" \
  -e HOME=/tmp \
  -it \
  -p 4567:4567 \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd)":/opt/bbs \
  shakiyam/bbs sh
