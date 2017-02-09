# Builds an image with confd installed

FROM alpine
MAINTAINER Shaun Murakami <stmuraka@us.ibm.com>
RUN apk update \
 && apk add \
        curl \
        openssl \
 && rm -rf /var/cache/apk/* /tmp/*

# install Confd : https://github.com/kelseyhightower/confd
ARG CONFD_VERSION
ENV CONFD_VERSION=${CONFD_VERSION}
ENV CONFD_RELEASES="https://github.com/kelseyhightower/confd/releases/latest" \
    CONFD_REPO="https://github.com/kelseyhightower/confd/releases/download" \
    CONFD_CONF_DIR=${CONFD_CONF_DIR:-/etc/confd/conf.d} \
    CONFD_TEMP_DIR=${CONFD_TEMP_DIR:-/etc/confd/templates}

WORKDIR /tmp
# If CONFD_VERSION is not specified, find the latest version and install
RUN if [ -z "${CONFD_VERSION+xxx}" ] || [ -z "${CONFD_VERSION}" -a "${CONFD_VERSION+xxx}" = "xxx" ]; then \
 	CONFD_VERSION=$(basename $(curl -w "%{url_effective}\n" -I -L -s -S ${CONFD_RELEASES} -o /dev/null) | tr -d 'v'); fi \
  && download_url="${CONFD_REPO}/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" \
  && wget "${download_url}" \
  && mv confd-${CONFD_VERSION}-linux-amd64 /usr/bin/confd

# Copy downloaded confd bin to the bin dir
RUN chmod 755 /usr/bin/confd \
  && mkdir -p ${CONFD_CONF_DIR} \
  && mkdir -p ${CONFD_TEMP_DIR} \
  && mkdir -p /var/run/confd \
  && mkdir -p /var/log/conf

CMD confd -version
