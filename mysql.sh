#!/bin/sh
docker-compose up -d db
docker exec -i -t bbs_db_1 \
    mysql -u bbs -D bbs -pbbs --default-character-set=utf8mb4
