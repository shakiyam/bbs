#!/bin/sh
docker run -i -t --rm \
-e http_proxy="${http_proxy:-}" \
-e https_proxy="${https_proxy:-}" \
-e DB_USER=bbs \
-e DB_PASSWORD=bbs \
-e DB_HOST=db \
-e DB_PORT=3306 \
-e DB_DATABASE=bbs \
-v "$(pwd)":/usr/src/app \
-w /usr/src/app \
-p 4567:4567 \
--net bbs_default \
--link bbs_db_1:db \
jruby:9-alpine bash
