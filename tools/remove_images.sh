#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

if [[ "$#" -ne 1 ]]; then
  echo_error 'Usage: remove_images.sh image_name'
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME

LATEST_IMAGE="$($CONTAINER_ENGINE image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly LATEST_IMAGE
if [[ -n "$LATEST_IMAGE" ]]; then
  $CONTAINER_ENGINE image rm -f "$LATEST_IMAGE"
fi
