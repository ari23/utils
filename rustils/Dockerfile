FROM bitnami/minideb:stretch

ARG RUSTUP_TOOLCHAIN
ARG SCCACHE_VERSION=0.2.12
ARG TARPAULIN_VERSION=0.9.0

ENV PATH=$PATH:/root/.cargo/bin

# clang + llvm + libclang for bindgen deps ~
# https://rust-lang.github.io/rust-bindgen/requirements.html
RUN install_packages \
    build-essential \
    ca-certificates \
    clang \
    curl \
    libclang-dev \
    libgnutls-openssl-dev \
    libssl-dev \
    llvm-dev \
    wget \
  && curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUSTUP_TOOLCHAIN \
  && rustup component add \
    clippy-preview \
    rustfmt-preview \
    rust-src \
  # cargo installs via cargo or as binaries
  # invoke cargo install independently otherwise partial failure has the incorrect exit code
  && cargo install cargo-watch \
  && cargo install cargo-expand \
  && cargo install hyperfine \
  && wget https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz -O - \
    | tar -xzf - -C /tmp \
  && wget https://github.com/xd009642/tarpaulin/releases/download/${TARPAULIN_VERSION}/cargo-tarpaulin-${TARPAULIN_VERSION}-travis.tar.gz -O - \
    | tar -xzf - -C /tmp \
  && mv /tmp/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache /root/.cargo/bin \
  && mv /tmp/cargo-tarpaulin /root/.cargo/bin \
  && rm -rf /root/.cargo/registry /var/lib/apt/lists /var/cache/apt/archives /tmp/
