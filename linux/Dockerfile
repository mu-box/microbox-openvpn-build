FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

# install some things
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git autoconf libtool net-tools iproute2 wget gawk build-essential crossbuild-essential-amd64 \
        crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-s390x bison python3

COPY build.sh glibc-arm32-static-mode.patch /root/