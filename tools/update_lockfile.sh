#!/bin/bash
set -eu -o pipefail

[[ -e Gemfile.lock ]] || touch Gemfile.lock
docker container run \
  --name update_lockfile$$ \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$PWD/Gemfile":/work/Gemfile:ro \
  -v "$PWD/Gemfile.lock":/work/Gemfile.lock \
  -w /work \
  ruby:alpine sh -c 'HOME=/tmp bundle lock --update'
