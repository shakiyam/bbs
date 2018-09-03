#!/bin/bash
set -eu -o pipefail

docker-compose up -d db
docker container run \
  -t \
  --name bbs_test \
  --net bbs_default \
  --rm \
  -e DB_USER=bbs \
  -e DB_PASSWORD=bbs \
  -e DB_HOST=db \
  -e DB_PORT=3306 \
  -e DB_DATABASE=bbs \
  -u "$(id -u):$(id -g)" \
  shakiyam/bbs "$@"
