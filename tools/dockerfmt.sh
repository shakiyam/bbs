#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v dockerfmt &>/dev/null; then
  dockerfmt "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name dockerfmt$$ \
    --rm \
    --platform linux/amd64 \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work \
    -w /work \
    ghcr.io/reteps/dockerfmt:latest "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name dockerfmt$$ \
    --rm \
    --platform linux/amd64 \
    --security-opt label=disable \
    -v "$PWD":/work \
    -w /work \
    ghcr.io/reteps/dockerfmt:latest "$@"
else
  echo_error 'dockerfmt could not be executed.'
  exit 1
fi
