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

if [[ -z "${MYSQL_USER:-}" || -z "${MYSQL_DATABASE:-}" ]]; then
  echo_error 'Required environment variable not defined.'
  exit 1
fi

if [[ ! -f secrets/mysql_password.txt ]]; then
  echo_error 'Secret file secrets/mysql_password.txt not found.'
  exit 1
fi

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE
if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

./tools/docker-compose-wrapper.sh up -d db
./tools/build.sh ghcr.io/shakiyam/bbs
$CONTAINER_ENGINE container run \
  --name bbs-development \
  --net bbs-default \
  --rm \
  "${ENGINE_OPTS[@]}" \
  -e DB_DATABASE="${MYSQL_DATABASE}" \
  -e DB_HOST=bbs-db \
  -e DB_PASSWORD_FILE=/run/secrets/mysql_password \
  -e DB_PORT=3306 \
  -e DB_USER="${MYSQL_USER}" \
  -e HOME=/tmp \
  -it \
  -p 4567:4567 \
  -v "$PWD":/opt/bbs \
  -v "$PWD"/secrets/mysql_password.txt:/run/secrets/mysql_password:ro \
  ghcr.io/shakiyam/bbs sh
