FROM debian:jessie
MAINTAINER Dave Henderson <dhenderson@gmail.com>

ENV MOSQUITTO_VERSION 1.4.2

# import "Roger A. Light <roger@atchoo.org>"'s signature
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B3E717B7

# Download and build
RUN buildDeps=' \
    curl \
    ca-certificates \
    build-essential \
    libwrap0-dev \
    libssl-dev \
    python-distutils-extra \
    libc-ares-dev \
    uuid-dev \
  ' \
  && set -x \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
  && curl -sSL http://mosquitto.org/files/source/mosquitto-${MOSQUITTO_VERSION}.tar.gz.asc -o /tmp/mosquitto.tar.gz.asc \
  && curl -sSL http://mosquitto.org/files/source/mosquitto-${MOSQUITTO_VERSION}.tar.gz -o /tmp/mosquitto.tar.gz \
  && gpg --verify /tmp/mosquitto.tar.gz.asc \
  && mkdir -p /usr/src/mosquitto \
  && tar zxf /tmp/mosquitto.tar.gz -C /usr/src/mosquitto --strip-components 1 \
  && rm /tmp/mosquitto.tar.gz* \
  && cd /usr/src/mosquitto \
  && make \
  && make install \
  && rm -rf /usr/src/mosquitto \
  && apt-get purge -y --auto-remove $buildDeps

RUN adduser --system --disabled-password --disabled-login mosquitto

EXPOSE 1883

CMD [ "/usr/local/sbin/mosquitto" ]
