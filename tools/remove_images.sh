#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker &>/dev/null; then
  DOCKER=docker
elif command -v podman &>/dev/null; then
  DOCKER=podman
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
readonly DOCKER

if [[ "$#" -ne 1 ]]; then
  echo_error 'Usage: remove_images.sh image_name'
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME

LATEST_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly LATEST_IMAGE
if [[ -n "$LATEST_IMAGE" ]]; then
  $DOCKER image rm -f "$LATEST_IMAGE"
fi
