FROM ruby:alpine
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
# hadolint ignore=DL3018
RUN apk update \
  && apk add --no-cache curl mysql-client mysql-dev \
  && apk add --no-cache --virtual=.build-dependencies gcc make musl-dev \
  && bundle install \
  && rm -rf /root/.bundle/cache \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -regex ".*\.[cho]" -delete \
  && apk del .build-dependencies
COPY app.rb /opt/bbs/
EXPOSE 4567
CMD ["ruby", "app.rb"]
HEALTHCHECK CMD curl -f -o /dev/null -s http://localhost:4567/ || exit 1
