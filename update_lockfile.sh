#!/bin/bash
set -eu -o pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
[[ -e "$script_dir/Gemfile.lock" ]] || touch "$script_dir/Gemfile.lock"
docker container run \
  --name update_lockfile$$ \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$script_dir/Gemfile":/work/Gemfile:ro \
  -v "$script_dir/Gemfile.lock":/work/Gemfile.lock \
  -w /work \
  ruby:alpine sh -c 'HOME=/tmp bundle lock --update'
