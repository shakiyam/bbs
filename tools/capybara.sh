#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v docker) ]]; then
  docker container run \
    --name capybara$$ \
    --net "${NETWORK:-bridge}" \
    --rm \
    -t \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/capybara "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name capybara$$ \
    --net "${NETWORK:-bridge}" \
    --rm \
    --security-opt label=disable \
    -t \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/capybara "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
