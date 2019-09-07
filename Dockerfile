##
## pull from our tcpreplay and rust-utils (rustils) containers
##
FROM williamofockham/tcpreplay:4.3.0 as tcpreplay
FROM williamofockham/rustils:nightly-2019-07-03 as rustils

##
## development image with DPDK
##

FROM williamofockham/dpdk:18.11.2

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG RUSTUP_TOOLCHAIN
ARG BACKPORTS_REPO=/etc/apt/sources.list.d/stretch-backports.list
ARG IOVISOR_REPO=/etc/apt/sources.list.d/iovisor.list

ENV PATH=$PATH:/root/.cargo/bin
ENV LD_LIBRARY_PATH=/opt/netbricks/target/native:$LD_LIBRARY_PATH
ENV CARGO_INCREMENTAL=0
ENV RUST_BACKTRACE=1

COPY --from=tcpreplay /usr/local/bin /usr/local/bin
COPY --from=tcpreplay /usr/local/share/man/man1 /usr/local/share/man/man1
COPY --from=rustils /root/.cargo/bin /root/.cargo/bin
COPY --from=rustils /root/.rustup /root/.rustup

RUN install_packages \
  # clang, libclang-dev and libsctp-dev are netbricks deps
  # cmake, git and libluajit-5.1-dev are moongen deps
  # libssl-dev and pkg-config are rust deps
    build-essential \
    ca-certificates \
    clang-3.9 \
    cmake \
    curl \
    gdb \
    gdbserver \
    git \
    libclang-3.9-dev \
    libcurl4-gnutls-dev \
    libgnutls30 \
    libgnutls-openssl-dev \
    libsctp-dev \
    libssl-dev \
    llvm-3.9-dev \
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
  # install luajit 2.1.0-beta3 from stretch backports
  && echo "deb http://ftp.debian.org/debian stretch-backports main" > ${BACKPORTS_REPO} \
  && apt-get update -o Dir::Etc::sourcelist=${BACKPORTS_REPO} \
  && apt-get -t stretch-backports install -y --no-install-recommends libluajit-5.1-dev \
  # install bcc tools
  && echo "deb [trusted=yes] http://repo.iovisor.org/apt/xenial xenial main" > ${IOVISOR_REPO} \
  && apt-get update -o Dir::Etc::sourcelist=${IOVISOR_REPO} \
  && apt-get -t xenial install -y --no-install-recommends bcc-tools \
  # cargo installs
  # invoke cargo install independently otherwise partial failure has the incorrect exit code
  && cargo install cargo-watch \
  && cargo install cargo-expand \
  && cargo install hyperfine \
  && cargo install sccache \
  && RUSTFLAGS="--cfg procmacro2_semver_exempt" cargo install -f cargo-tarpaulin \
  && rm -rf /root/.cargo/registry /var/lib/apt/lists /var/cache/apt/archives

ENV RUSTC_WRAPPER=sccache

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
