#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker &>/dev/null; then
  docker container run \
    --name "rubocop_$(uuidgen | head -c8)" \
    --rm \
    -t \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/rubocop "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "rubocop_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -t \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/rubocop "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
