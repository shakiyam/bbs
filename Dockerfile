FROM docker.io/library/ruby:4.0.5-slim-trixie AS builder
WORKDIR /opt/bbs
COPY Gemfile Gemfile.lock ./
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install build-essential \
  && rm -rf /var/lib/apt/lists/* \
  && bundle install \
  && rm -rf /root/.bundle/cache \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -regex ".*\.[cho]" -delete \
  && find /usr/local/bundle/gems/ \( -name "*.md" -o -name "*.txt" -o -name "CHANGELOG*" -o -name "README*" \) -delete \
  && find /usr/local/bundle/gems/ -type d -name test -exec rm -rf {} + 2>/dev/null || true \
  && find /usr/local/bundle/gems/ -type d -name spec -exec rm -rf {} + 2>/dev/null || true

FROM docker.io/library/ruby:4.0.5-slim-trixie
COPY --from=builder /usr/local/bundle /usr/local/bundle
# TODO: Remove json cleanup once base image includes json >= 2.19.2 (CVE-2026-33210)
# TODO: Remove net-imap cleanup once base image includes net-imap >= 0.6.4 (CVE-2026-42246)
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends install curl \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /usr/local/lib/ruby/gems/*/specifications/default/json-*.gemspec \
  && rm -f /usr/local/lib/ruby/gems/*/specifications/net-imap-*.gemspec \
  && rm -rf /usr/local/lib/ruby/gems/*/gems/net-imap-* \
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
