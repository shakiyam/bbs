#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh

case $(uname -m) in
  x86_64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.4
    ;;
  aarch64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.4-aarch64
    ;;
  *)
    echo_error "Error: Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac
readonly MYSQL_IMAGE

set +o pipefail
MYSQL_PASSWORD=$(tr -dc '0-9A-Za-z' </dev/urandom | head -c 16)
readonly MYSQL_PASSWORD

MYSQL_ROOT_PASSWORD=$(tr -dc '0-9A-Za-z' </dev/urandom | head -c 16)
readonly MYSQL_ROOT_PASSWORD
set -o pipefail

[[ -f .env ]] && echo_warn "Warning: Overwriting existing .env file"

(
  umask 077
  cat >.env <<EOF
MYSQL_DATABASE=bbs
MYSQL_IMAGE=$MYSQL_IMAGE
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_USER=bbs
EOF
)

echo_success ".env file generated successfully"
