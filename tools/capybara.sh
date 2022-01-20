#!/bin/bash
set -eu -o pipefail

if [[ $(command -v docker) ]]; then
  docker container run \
    --name capybara$$ \
    --net "${NETWORK:-bridge}" \
    --rm \
    -t \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/capybara "$@"
else
  podman container run \
    --name capybara$$ \
    --net "${NETWORK:-bridge}" \
    --rm \
    --security-opt label=disable \
    -t \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/capybara "$@"
fi
