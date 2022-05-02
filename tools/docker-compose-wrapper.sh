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

if [[ $(command -v docker-compose) ]]; then
  docker-compose "$@"
else
  docker compose "$@"
fi
