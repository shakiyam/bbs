# bbs_web

FROM jruby:9

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install
COPY app.rb /usr/src/app/
COPY spec /usr/src/app/spec

EXPOSE 4567
CMD ["ruby", "app.rb"]
HEALTHCHECK --start-period=30s \
  CMD curl -f -o /dev/null -s http://$HOSTNAME:4567/ || exit 1
