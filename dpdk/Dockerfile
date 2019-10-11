##
## compiling DPDK from source
##

FROM ubuntu:bionic as builder

ARG DPDK_VERSION
ARG RTE_SDK=/tmp/dpdk-stable-${DPDK_VERSION}
ARG CFLAGS="-g3 -Wno-error=maybe-uninitialized -fPIC"

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    libnuma-dev \
    libpcap-dev \
    libz-dev \
    linux-headers-$(uname -r) \
    xz-utils \
  && cd /tmp \
  && curl -sSf https://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz | tar -xJv

COPY common_linuxapp-18.11.container ${RTE_SDK}/config/common_linuxapp
COPY defconfig_x86_64-nhm-linuxapp-gcc ${RTE_SDK}/config/defconfig_x86_64-nhm-linuxapp-gcc

WORKDIR ${RTE_SDK}

RUN make config T=x86_64-nhm-linuxapp-gcc EXTRA_CFLAGS="${CFLAGS}" \
  && make -j$(nproc) EXTRA_CFLAGS="${CFLAGS}" \
  && make install

##
## image with DPDK dev libs and utils
##
FROM ubuntu:bionic as dpdk

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    iproute2 \
    libnuma-dev \
    libpcap-dev \
    pciutils \
    python \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/lib /usr/local/lib/dpdk
COPY --from=builder /usr/local/sbin /usr/local/sbin
COPY --from=builder /usr/local/share/dpdk /usr/local/share/dpdk

ENV RTE_SDK=/opt/dpdk

RUN mkdir -p ${RTE_SDK}/build \
  && ln -s /usr/local/lib/dpdk ${RTE_SDK}/build/lib \
  && ln -s /usr/local/include/dpdk ${RTE_SDK}/build/include

##
## dpdk-devbind utility
##
FROM ubuntu:bionic as dpdk-devbind

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    iproute2 \
    pciutils \
    python \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=builder /usr/local/share/dpdk/usertools/dpdk-devbind.py /usr/local/share/dpdk/usertools/dpdk-devbind.py
COPY --from=builder /usr/local/sbin/dpdk-devbind /usr/local/sbin/dpdk-devbind
