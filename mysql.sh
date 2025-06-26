#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh

DOCKER=$(command -v docker || command -v podman)
readonly DOCKER

if [[ -z "$($DOCKER ps --filter "name=^bbs-db$" --filter "status=running" --quiet)" ]]; then
  echo_error 'bbs-db container is not running'
  exit 1
fi

if [[ -t 0 ]]; then
  TTY_OPTION='-t'
else
  TTY_OPTION=''
fi
readonly TTY_OPTION

# shellcheck disable=SC2016
MYSQL_CMD='MYSQL_PWD=$MYSQL_PASSWORD mysql --host=bbs-db --port=3306 --database=$MYSQL_DATABASE --user=$MYSQL_USER --default-character-set=utf8mb4'
$DOCKER exec -i $TTY_OPTION bbs-db sh -c "$MYSQL_CMD"
