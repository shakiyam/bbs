FROM public.ecr.aws/docker/library/ruby:3.4.4-slim-bookworm AS builder
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock /opt/bbs/
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install build-essential \
  && rm -rf /var/lib/apt/lists/* \
  && bundle install \
  && rm -rf /root/.bundle/cache \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -regex ".*\.[cho]" -delete

FROM public.ecr.aws/docker/library/ruby:3.4.4-slim-bookworm
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install curl \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN mkdir -p /opt/bbs
WORKDIR /opt/bbs
COPY app.rb /opt/bbs/
COPY views /opt/bbs/views
EXPOSE 4567
USER nobody:nogroup
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
CMD ["ruby", "app.rb"]
