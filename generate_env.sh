#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  . .env
fi

case $(uname -m) in
  x86_64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.4.10
    ;;
  aarch64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.4.10-aarch64
    ;;
  *)
    echo_error "Error: Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac
readonly MYSQL_IMAGE

random_string() {
  set +o pipefail
  tr -dc '0-9A-Za-z' </dev/urandom | head -c "$1"
  set -o pipefail
}

if [[ -f secrets/mysql_password.txt ]]; then
  MYSQL_PASSWORD=$(<secrets/mysql_password.txt)
fi
if [[ -f secrets/mysql_root_password.txt ]]; then
  MYSQL_ROOT_PASSWORD=$(<secrets/mysql_root_password.txt)
fi
MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(random_string 16)}
readonly MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-$(random_string 16)}
readonly MYSQL_ROOT_PASSWORD
SESSION_SECRET=${SESSION_SECRET:-$(random_string 64)}
readonly SESSION_SECRET

mkdir -p secrets
chmod 700 secrets
printf '%s' "$MYSQL_PASSWORD" >secrets/mysql_password.txt
printf '%s' "$MYSQL_ROOT_PASSWORD" >secrets/mysql_root_password.txt
chmod 644 secrets/mysql_password.txt secrets/mysql_root_password.txt

(
  umask 077
  cat >.env <<EOF
MYSQL_DATABASE=bbs
MYSQL_IMAGE=$MYSQL_IMAGE
MYSQL_USER=bbs
SESSION_SECRET=$SESSION_SECRET
EOF
)

echo_success '.env and secret files generated successfully'
