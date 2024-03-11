FROM public.ecr.aws/docker/library/ruby:3.3.0-slim-bookworm
ENV GEM_HOME=/usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install build-essential curl \
  && rm -rf /var/lib/apt/lists/*
# hadolint ignore=DL3059
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
RUN bundle install
COPY app.rb /opt/bbs/
EXPOSE 4567
USER nobody:nogroup
CMD ["ruby", "app.rb"]
