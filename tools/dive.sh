#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v dive &>/dev/null; then
  dive "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name "dive_$(uuidgen | head -c8)" \
    --rm \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    ghcr.io/wagoodman/dive "$@"
elif command -v podman &>/dev/null; then
  PODMAN_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
  if [[ ! -S "$PODMAN_SOCKET" ]]; then
    echo_error "Podman socket not found: $PODMAN_SOCKET"
    echo_error "Run: systemctl --user enable --now podman.socket"
    exit 1
  fi
  podman container run \
    --name "dive_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PODMAN_SOCKET":/run/podman/podman.sock:ro \
    -e DOCKER_HOST=unix:///run/podman/podman.sock \
    ghcr.io/wagoodman/dive "$@"
else
  echo_error 'dive could not be executed.'
  exit 1
fi
