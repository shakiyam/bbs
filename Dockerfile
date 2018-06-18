# bbs_web

FROM ruby:2.5

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install
COPY app.rb /usr/src/app/

EXPOSE 4567
CMD ["ruby","app.rb"]
