# bbs_web

FROM jruby:9-alpine
MAINTAINER Shinichi Akiyama <shinichi.akiyama@gmail.com>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
RUN bundle install
COPY app.rb /usr/src/app/

EXPOSE 4567
CMD ["ruby","app.rb"]
