#!/bin/bash
set -eu -o pipefail

if [[ "$#" -ne 1 ]]; then
  echo "Usage: remove_images.sh image_name"
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME

DOCKER=$(command -v docker || command -v podman)
readonly DOCKER
LATEST_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly LATEST_IMAGE
if [[ -n "$LATEST_IMAGE" ]]; then
  $DOCKER image rm -f "$LATEST_IMAGE"
fi
