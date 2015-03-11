FROM ubuntu:14.04
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install git curl build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY skarnet-builder /skarnet-builder

RUN chown -R nobody:nogroup /skarnet-builder

USER nobody
ENV HOME /skarnet-builder
WORKDIR /skarnet-builder

CMD ["/skarnet-builder/build-wrapper"]
