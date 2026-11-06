#!/bin/bash
set -Eeu -o pipefail

# TODO: Remove once base image includes json >= 2.19.9 (CVE-2026-33210, CVE-2026-54696)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

IMAGE_NAME=ghcr.io/shakiyam/bbs:latest
readonly IMAGE_NAME

# shellcheck disable=SC2016
if ! JSON_LOADED=$($CONTAINER_ENGINE container run \
  --name "test_json_$(uuidgen | head -c8)" \
  --rm \
  --pull=never \
  --entrypoint ruby \
  "$IMAGE_NAME" -e '
    require "json"
    path = $LOADED_FEATURES.grep(%r{/json/version\.rb\z}).first.to_s
    puts "#{JSON::VERSION} from #{path}"
    exit(Gem::Version.new(JSON::VERSION) >= Gem::Version.new("2.19.9") && path.start_with?("/usr/local/bundle/"))
  '); then
  echo_error "Test failed: json ${JSON_LOADED} is loaded instead of >= 2.19.9 from /usr/local/bundle."
  exit 1
fi

echo_success "Test passed: json ${JSON_LOADED} is loaded."
