#!/bin/bash
set -eu -o pipefail

docker container run \
  --name bbs_update_lockfile \
  --rm \
  -e http_proxy="${http_proxy:-}" \
  -e https_proxy="${https_proxy:-}" \
  -v "$(pwd)":/opt/bbs \
  -u "$(id -u):$(id -g)" \
  -w /opt/bbs \
  jruby:9 bundle lock --update
