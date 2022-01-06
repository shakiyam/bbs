#!/bin/bash
set -eu -o pipefail

docker container run \
  --name capybara$$ \
  --net bbs_default \
  --rm \
  -t \
  -u "$(id -u):$(id -g)" \
  -v "$PWD":/work:ro \
  shakiyam/capybara "$@"
