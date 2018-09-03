#!/bin/bash
set -eu -o pipefail

docker container run \
  --name bbs_update_lockfile \
  --rm \
  -e http_proxy="${http_proxy:-}" \
  -e https_proxy="${https_proxy:-}" \
  -v "$(pwd)":/usr/src/app \
  -u "$(id -u):$(id -g)" \
  -w /usr/src/app \
  jruby:9 bundle lock --update
