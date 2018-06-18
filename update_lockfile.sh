#!/bin/sh
docker run --rm \
-e http_proxy="${http_proxy:-}" \
-e https_proxy="${https_proxy:-}" \
-v "$(pwd)":/usr/src/app \
-w /usr/src/app \
ruby:2.5 bundle lock --update
