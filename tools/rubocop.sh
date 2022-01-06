#!/bin/bash
set -eu -o pipefail

docker container run \
  --name rubocop$$ \
  --rm \
  -t \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work:ro \
  shakiyam/rubocop "$@"
