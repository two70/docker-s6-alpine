ARG ALPINE_VERSION
FROM alpine${ALPINE_VERSION}

# TARGETPLATFORM is injected from the buildx command in the github action (.github/workflows/docker-publish.yml)
# https://docs.docker.com/engine/reference/commandline/buildx_build/#build-arg
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64} S6_KEEP_ENV=1

# COPY qemu/qemu-${TARGETPLATFORM}-static /usr/bin/

RUN set -x && apk add --no-cache curl coreutils tzdata shadow \
  && case "${TARGETPLATFORM}" in \
    linux/amd64) S6_ARCH='amd64';; \
    linux/arm64) S6_ARCH='aarch64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-${S6_ARCH}.tar.gz | tar xvzf - -C / \
  && groupmod -g 911 users && \
  useradd -u 911 -U -d /config -s /bin/false abc && \
  usermod -G users abc && \
  mkdir -p /app /config /defaults && \
  apk del --no-cache curl \
  apk del --purge \
  rm -rf /tmp/*

ENTRYPOINT [ "/init" ]
