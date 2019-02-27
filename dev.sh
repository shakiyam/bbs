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
./build.sh
docker run \
  -it \
  --name bbs_development \
  --net bbs_default \
  --rm \
  -p 4567:4567 \
  -e http_proxy="${http_proxy:-}" \
  -e https_proxy="${https_proxy:-}" \
  -e DB_USER="${MYSQL_USER}" \
  -e DB_PASSWORD="${MYSQL_PASSWORD}" \
  -e DB_HOST=db \
  -e DB_PORT=3306 \
  -e DB_DATABASE="${MYSQL_DATABASE}" \
  -v "$(pwd)":/opt/bbs \
  -u "$(id -u):$(id -g)" \
  shakiyam/bbs bash
