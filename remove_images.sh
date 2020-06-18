#!/bin/bash
set -eu -o pipefail

readonly IMAGE_NAME='shakiyam/bbs'
readonly LATEST_IMAGE="$(docker image ls -q $IMAGE_NAME:latest)"
if [[ -n "$LATEST_IMAGE" ]]; then
  docker image rm -f "$LATEST_IMAGE"
fi
