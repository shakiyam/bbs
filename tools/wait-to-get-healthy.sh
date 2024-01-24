#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker &>/dev/null; then
  DOCKER=docker
  HEALTHCHECK_QUERY='{{.State.Health.Status}}'
elif command -v podman &>/dev/null; then
  DOCKER=podman
  HEALTHCHECK_QUERY='{{.State.Healthcheck.Status}}'
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
readonly DOCKER
readonly HEALTHCHECK_QUERY

if [[ $# -ne 1 ]]; then
  echo_error 'Container ID or NAME is required.'
  exit 1
fi
CONTAINER=$1
readonly CONTAINER

# echo_info
echo -n "Waiting for $CONTAINER to get healthy ..."
while true; do
  status="$($DOCKER inspect -f '{{.State.Status}}' "$CONTAINER")"
  if [[ $status != "running" ]]; then
    echo_error " Container $CONTAINER is $status."
    exit 1
  fi
  if [[ "$($DOCKER inspect -f $HEALTHCHECK_QUERY "$CONTAINER")" == "healthy" ]]; then
    break
  fi
  sleep 1
  echo -n '.'
done
echo_success ' done.'
