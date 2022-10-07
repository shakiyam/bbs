#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v docker-compose) ]]; then
  DOCKER_COMPOSE=docker-compose
elif command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE='docker compose'
else
  echo_error 'Docker Compose is not installed.'
  exit 1
fi
readonly DOCKER_COMPOSE

if [[ ! -e .env ]]; then
  echo_error 'Environment file .env not found.'
  exit 1
fi
# shellcheck disable=SC1091
. .env

if [[ -z "${MYSQL_ROOT_PASSWORD:-}" || -z "${MYSQL_USER:-}" || -z "${MYSQL_PASSWORD:-}" || -z "${MYSQL_DATABASE:-}" ]]; then
  echo_error 'Required environment variable not defined.'
  exit 1
fi

$DOCKER_COMPOSE "$@"
