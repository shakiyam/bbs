#!/bin/bash
# Sourced by the MySQL image entrypoint during first initialization.
# ${mysql[@]}, MYSQL_USER and MYSQL_DATABASE are provided by the entrypoint.

password="$(cat /run/secrets/mysql_password)"
# shellcheck disable=SC2154
echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${password}' ;" | "${mysql[@]}"
echo "GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' ;" | "${mysql[@]}"
