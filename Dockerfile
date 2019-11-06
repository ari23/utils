ARG RUSTUP_TOOLCHAIN
ARG TCPREPLAY_VERSION
ARG DPDK_VERSION

##
## pull from our tcpreplay and rust-utils (rustils) containers
##
FROM williamofockham/tcpreplay:$TCPREPLAY_VERSION as tcpreplay
FROM williamofockham/rustils:$RUSTUP_TOOLCHAIN as rustils

##
## development image with DPDK
##

FROM williamofockham/dpdk:$DPDK_VERSION

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG IOVISOR_REPO=/etc/apt/sources.list.d/iovisor.list

ENV PATH=$PATH:/root/.cargo/bin
ENV CARGO_INCREMENTAL=0
ENV RUST_BACKTRACE=1

COPY --from=tcpreplay /usr/local/bin /usr/local/bin
COPY --from=tcpreplay /usr/local/share/man/man1 /usr/local/share/man/man1
COPY --from=rustils /root/.cargo/bin /root/.cargo/bin
COPY --from=rustils /root/.rustup /root/.rustup

# cmake, git and libluajit-5.1-dev are moongen deps
# gnuplot for criterion/bench plots
# libssl-dev and pkg-config are general rust deps
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    gdb \
    gdbserver \
    git \
    gnuplot \
    libclang-dev \
    libcurl4-gnutls-dev \
    libgnutls30 \
    libgnutls-openssl-dev \
    libluajit-5.1-dev \
    libssl-dev \
    libtbb-dev \
    llvm-dev \
    pkg-config \
    python-pip \
    python-setuptools \
    python-wheel \
    sudo \
    tcpdump \
  # pyroute2 and toml are agent deps
  && pip install \
    bitstruct \
    pyroute2 \
    toml \
  # install bcc tools
  && echo "deb [trusted=yes] http://repo.iovisor.org/apt/xenial xenial main" > ${IOVISOR_REPO} \
  && apt-get update -o Dir::Etc::sourcelist=${IOVISOR_REPO} \
  && apt-get -t xenial install -y --no-install-recommends bcc-tools \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RUSTC_WRAPPER=sccache

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
