#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 1 ]]; then
   echo -e "\033[36mContainer ID or NAME is required\033[0m"
   exit 1
fi

echo -n "Waiting for $1 to get healthy ..."
until [[ "$(docker inspect -f '{{.State.Health.Status}}' "$1")" == "healthy" ]]; do
  sleep 1
  echo -n .
done
echo -e " \033[32mdone\033[0m"
