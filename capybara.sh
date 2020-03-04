#!/bin/bash
set -eu -o pipefail

docker container run \
  --name capybara$$ \
  --net bbs_default \
  --rm \
  -t \
  -u "$(id -u):$(id -g)" \
  -v "$(cd "$(dirname "$0")" && pwd)":/work:ro \
  shakiyam/capybara "$@"
