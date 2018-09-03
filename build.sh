#!/bin/bash
set -eu -o pipefail

current_image="$(docker image ls -q shakiyam/bbs:latest)"
docker image build \
  --build-arg http_proxy="${http_proxy:-}" \
  --build-arg https_proxy="${https_proxy:-}" \
  -t shakiyam/bbs .
latest_image="$(docker image ls -q shakiyam/bbs:latest)"
if [ "$current_image" != "$latest_image" ]; then
  docker image tag shakiyam/bbs:latest shakiyam/bbs:"$(date +%Y%m%d%H%S)"
fi
