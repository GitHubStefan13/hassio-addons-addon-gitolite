ARG BUILD_FROM=homeassistant/base:7.0.0
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV GITOLITE_TAG="v3.6.11"

# Install requirements for add-on
RUN apk add --no-cache   \                                                                                                      openssh-server   \
        git=2.24.1-r0    \
        libbz2=1.0.8-r1  \                                                                                                      perl=5.30.1-r0   \
    \
    && addgroup -S git \
    && adduser -S -s /bin/bash -h /home/git git git \
    && git clone --branch "${GITOLITE_TAG}" --depth=1 \                                                                         https://github.com/sitaramc/gitolite.git /home/git/gitolite \
    && git -C /home/git/gitolite checkout -b master \
    \
    && mkdir -p /data/gitolite/bin
#    && su git -c "/home/git/gitolite/install -ln /data/gitolite/bin"

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Gitolite" \
    io.hass.description="Gitolite allows you to host a central Gitolite server" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Stefan Unruh <dsgamingdevs@gmail.com>" \
    org.label-schema.description="Gitolite allows you to host a central Gitolite server" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Gitolite" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-gitolite" \
    org.label-schema.vendor="Community Hass.io Addons"
