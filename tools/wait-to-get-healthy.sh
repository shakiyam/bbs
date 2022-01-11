#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 1 ]]; then
  echo -e "\033[36mContainer ID or NAME is required\033[0m"
  exit 1
fi

DOCKER=$(command -v docker || command -v podman)
if [[ $(command -v docker) ]]; then
  DOCKER=docker
  HEALTHCHECK_QUERY='{{.State.Health.Status}}'
else
  DOCKER=podman
  HEALTHCHECK_QUERY='{{.State.Healthcheck.Status}}'
fi
readonly DOCKER

echo -n "Waiting for $1 to get healthy ..."
while true; do
  status="$($DOCKER inspect -f '{{.State.Status}}' "$1")"
  if [[ $status != "running" ]]; then
    echo -e "\n\033[36mContainer $1 is $status\033[0m"
    exit 1
  fi
  if [[ "$($DOCKER inspect -f $HEALTHCHECK_QUERY "$1")" == "healthy" ]]; then
    break
  fi
  sleep 1
  echo -n .
done
echo -e " \033[32mdone\033[0m"
