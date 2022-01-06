#!/bin/bash
set -eu -o pipefail

IMAGE_NAME="$1"
readonly IMAGE_NAME
LATEST_IMAGE="$(docker image ls -q "$IMAGE_NAME":latest)"
readonly LATEST_IMAGE
if [[ -n "$LATEST_IMAGE" ]]; then
  docker image rm -f "$LATEST_IMAGE"
fi
