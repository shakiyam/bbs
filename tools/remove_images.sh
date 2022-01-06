#!/bin/bash
set -eu -o pipefail

readonly IMAGE_NAME='shakiyam/bbs'
LATEST_IMAGE="$(docker image ls -q $IMAGE_NAME:latest)"
readonly LATEST_IMAGE
if [[ -n "$LATEST_IMAGE" ]]; then
  docker image rm -f "$LATEST_IMAGE"
fi
