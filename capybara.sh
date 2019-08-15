#!/bin/bash
set -eu -o pipefail

readonly IMAGE_NAME='shakiyam/capybara'

docker container run \
  -t \
  --name bbs_test \
  --net bbs_default \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(cd "$(dirname "$0")" && pwd)":/work:ro \
  "$IMAGE_NAME" "$@"
