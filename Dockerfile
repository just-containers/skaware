FROM ubuntu:14.04
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install git curl build-essential

RUN mkdir -p /build && \
    mkdir -p /dist

COPY rootfs /
RUN chmod +x /build-latest       \
             /build-latest-git   \
             /install-latest     \
             /install-latest-git

VOLUME "/dist"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/build-latest"]