#!/bin/bash
set -Eeu -o pipefail

MYSQL_PWD="$(cat /run/secrets/mysql_password)" mysql --host=bbs-db --port=3306 \
  --database="$MYSQL_DATABASE" --user="$MYSQL_USER" \
  --silent --execute='SELECT 1' >/dev/null
