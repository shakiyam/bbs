#!/bin/bash
set -eu -o pipefail

case $(uname -m) in
  x86_64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.3
    ;;
  aarch64)
    MYSQL_IMAGE=container-registry.oracle.com/mysql/community-server:8.3-aarch64
    ;;
esac
readonly MYSQL_IMAGE

MYSQL_PASSWORD=$(tr -dc '0-9A-Za-z' </dev/urandom | head -c 16|| true)
readonly MYSQL_PASSWORD

MYSQL_ROOT_PASSWORD=$(tr -dc '0-9A-Za-z' </dev/urandom | head -c 16 || true)
readonly MYSQL_ROOT_PASSWORD

cat >.env <<EOF
MYSQL_DATABASE=bbs
MYSQL_IMAGE=$MYSQL_IMAGE
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_USER=bbs
EOF
