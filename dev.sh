#!/bin/bash
set -eu -o pipefail

docker-compose up -d db
./build.sh
docker run \
  -it \
  --name bbs_development \
  --net bbs_default \
  --rm \
  -p 4567:4567 \
  -e http_proxy="${http_proxy:-}" \
  -e https_proxy="${https_proxy:-}" \
  -e DB_USER=bbs \
  -e DB_PASSWORD=bbs \
  -e DB_HOST=db \
  -e DB_PORT=3306 \
  -e DB_DATABASE=bbs \
  -v "$(pwd)":/usr/src/app \
  -u "$(id -u):$(id -g)" \
  shakiyam/bbs bash
