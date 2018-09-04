# bbs_web

FROM jruby:9

RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
RUN bundle install
COPY app.rb /opt/bbs/
COPY spec /opt/bbs/spec

EXPOSE 4567
CMD ["ruby", "app.rb"]
HEALTHCHECK --start-period=30s \
  CMD curl -f -o /dev/null -s http://$HOSTNAME:4567/ || exit 1
