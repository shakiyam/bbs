#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker-compose &>/dev/null; then
  DOCKER_COMPOSE=docker-compose
elif command -v docker &>/dev/null && docker compose version &>/dev/null; then
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

$DOCKER_COMPOSE "$@"
