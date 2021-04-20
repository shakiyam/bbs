FROM ruby:alpine
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache curl
# hadolint ignore=DL3059
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
RUN bundle install
COPY app.rb /opt/bbs/

EXPOSE 4567
CMD ["ruby", "app.rb"]
HEALTHCHECK CMD curl -f -o /dev/null -s http://localhost:4567/ || exit 1
