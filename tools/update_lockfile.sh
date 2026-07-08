#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

readonly RUBY_IMAGE="docker.io/library/ruby:4.0.5-slim-trixie"

[[ -e Gemfile.lock ]] || touch Gemfile.lock
if command -v docker &>/dev/null; then
  docker container run \
    --name "update_lockfile_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD/Gemfile":/work/Gemfile:ro \
    -v "$PWD/Gemfile.lock":/work/Gemfile.lock \
    -w /work \
    "$RUBY_IMAGE" sh -c 'HOME=/tmp bundle lock --update --add-platform aarch64-linux x86_64-linux'
elif command -v podman &>/dev/null; then
  podman container run \
    --name "update_lockfile_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD/Gemfile":/work/Gemfile:ro \
    -v "$PWD/Gemfile.lock":/work/Gemfile.lock \
    -w /work \
    "$RUBY_IMAGE" sh -c 'HOME=/tmp bundle lock --update --add-platform aarch64-linux x86_64-linux'
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
