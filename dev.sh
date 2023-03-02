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
./tools/build.sh ghcr.io/shakiyam/bbs
if [[ $(command -v docker) ]]; then
  docker container run \
    --name bbs-development \
    --net bbs-default \
    --rm \
    -e DB_DATABASE="${MYSQL_DATABASE}" \
    -e DB_HOST=bbs-db \
    -e DB_PASSWORD="${MYSQL_PASSWORD}" \
    -e DB_PORT=3306 \
    -e DB_USER="${MYSQL_USER}" \
    -e HOME=/tmp \
    -it \
    -p 4567:4567 \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/opt/bbs \
    ghcr.io/shakiyam/bbs sh
else
  podman container run \
    --name bbs-development \
    --net bbs-default \
    --rm \
    --security-opt label=disable \
    -e DB_DATABASE="${MYSQL_DATABASE}" \
    -e DB_HOST=bbs-db \
    -e DB_PASSWORD="${MYSQL_PASSWORD}" \
    -e DB_PORT=3306 \
    -e DB_USER="${MYSQL_USER}" \
    -e HOME=/tmp \
    -it \
    -p 4567:4567 \
    -v "$PWD":/opt/bbs \
    ghcr.io/shakiyam/bbs sh
fi
