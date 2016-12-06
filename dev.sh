#!/bin/sh
docker run -i -t --rm \
-e http_proxy="$http_proxy" \
-e https_proxy="$https_proxy" \
-e DB_ENV_MYSQL_USER=bbs \
-e DB_ENV_MYSQL_PASSWORD=bbs \
-e DB_ENV_MYSQL_DATABASE=bbs \
-e DB_PORT_3306_TCP_ADDR=bbs_db_1 \
-e DB_PORT_3306_TCP_PORT=3306 \
-v /vagrant/bbs:/usr/src/app \
-w /usr/src/app \
-p 4567:4567 \
--net bbs_default \
--link bbs_db_1:db \
jruby:9-alpine bash
