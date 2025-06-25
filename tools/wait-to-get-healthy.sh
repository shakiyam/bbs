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

if [[ -z "$($DOCKER container ls --all --filter "name=^${CONTAINER}$" --quiet)" ]]; then
  echo_error "Container $CONTAINER does not exist."
  exit 1
fi

if ! $DOCKER inspect -f "$HEALTHCHECK_QUERY" "$CONTAINER" >/dev/null 2>&1; then
  echo_warn "No healthcheck defined for $CONTAINER, waiting for running status only."
  echo -n "Waiting for $CONTAINER to be running ..."
  healthcheck_mode=false
else
  echo -n "Waiting for $CONTAINER to get healthy ..."
  healthcheck_mode=true
fi

readonly TIMEOUT=60
start_time=$(date +%s)
readonly start_time
while true; do
  elapsed=$(($(date +%s) - start_time))
  if [[ $elapsed -ge $TIMEOUT ]]; then
    echo_error " Timeout after ${TIMEOUT} seconds."
    exit 1
  fi
  status="$($DOCKER inspect -f '{{.State.Status}}' "$CONTAINER")"
  if [[ $status != "running" ]]; then
    echo_error " Container $CONTAINER is $status."
    exit 1
  fi
  if [[ $healthcheck_mode == false ]]; then
    break
  else
    health_status="$($DOCKER inspect -f "$HEALTHCHECK_QUERY" "$CONTAINER")"
    case "$health_status" in
      "healthy")
        break
        ;;
      "unhealthy")
        echo_error " Container $CONTAINER is unhealthy."
        exit 1
        ;;
      "starting")
        # Continue waiting
        ;;
    esac
  fi
  sleep 1
  echo -n '.'
done
echo_success ' done.'
