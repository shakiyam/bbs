FROM public.ecr.aws/docker/library/ruby:3.4.5-slim-trixie AS builder
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock ./
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install build-essential \
  && rm -rf /var/lib/apt/lists/* \
  && bundle install \
  && rm -rf /root/.bundle/cache \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -regex ".*\.[cho]" -delete

FROM public.ecr.aws/docker/library/ruby:3.4.5-slim-trixie
COPY --from=builder /usr/local/bundle /usr/local/bundle
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install curl \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd --gid 5501 bbs \
  && useradd --uid 5501 --gid bbs --home-dir /opt/bbs --shell /bin/false --create-home --skel /dev/null bbs
WORKDIR /opt/bbs
COPY --chown=bbs:bbs app.rb ./
COPY --chown=bbs:bbs views ./views
COPY --chown=bbs:bbs public ./public
EXPOSE 4567
USER bbs:bbs
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
CMD ["ruby", "app.rb"]
