#!/bin/bash
set -eu -o pipefail

readonly IMAGE_NAME='shakiyam/bbs'

current_image="$(docker image ls -q $IMAGE_NAME:latest)"
docker image build -t "$IMAGE_NAME" .
latest_image="$(docker image ls -q $IMAGE_NAME:latest)"
if [[ "$current_image" != "$latest_image" ]]; then
  docker image tag $IMAGE_NAME:latest $IMAGE_NAME:"$(date +%Y%m%d%H%S)"
fi
