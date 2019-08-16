FROM ruby:alpine

RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
RUN bundle install
COPY app.rb /opt/bbs/

EXPOSE 4567
CMD ["ruby", "app.rb"]
HEALTHCHECK --start-period=30s \
  CMD curl -f -o /dev/null -s http://$HOSTNAME:4567/ || exit 1
