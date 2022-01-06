#!/bin/bash
set -eu -o pipefail

if [[ $(uname -m) == 'aarch64' ]]; then
  echo 'hadolint is not yet supported on ARM.'
  exit 0
fi

docker container run \
  --name hadolint$$ \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work:ro \
  -w /work \
  hadolint/hadolint hadolint "$@"
