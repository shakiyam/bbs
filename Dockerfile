FROM docker.io/ruby:3.1-alpine3.16
# hadolint ignore=DL3018
RUN apk add --no-cache curl
# hadolint ignore=DL3059
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
RUN bundle install
COPY app.rb /opt/bbs/
EXPOSE 4567
USER nobody:nobody
CMD ["ruby", "app.rb"]
