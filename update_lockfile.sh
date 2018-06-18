#!/bin/sh
docker run --rm \
-e http_proxy="${http_proxy:-}" \
-e https_proxy="${https_proxy:-}" \
-v "$(pwd)":/usr/src/app \
-w /usr/src/app \
jruby:9-alpine bundle lock --update
