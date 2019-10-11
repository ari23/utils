FROM ubuntu:bionic

ARG TCPREPLAY_VERSION

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    file \
    libpcap-dev \
    tcpdump \
  && cd /tmp \
  && curl -sSfL https://github.com/appneta/tcpreplay/releases/download/v${TCPREPLAY_VERSION}/tcpreplay-${TCPREPLAY_VERSION}.tar.xz | tar -xJv \
  && cd tcpreplay-${TCPREPLAY_VERSION} \
  # replace the occurrences of ETH_P_ALL with ETH_P_IP
  && sed -i 's|ETH_P_ALL|'"ETH_P_IP"'|g' src/common/sendpacket.c \
  && ./configure \
  && make \
  && make install \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives
