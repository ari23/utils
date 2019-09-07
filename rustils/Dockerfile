FROM bitnami/minideb:stretch

ARG RUSTUP_TOOLCHAIN

ENV PATH=$PATH:/root/.cargo/bin

# clang + llvm + libclang (all version 3.9) for bindgen deps ~
# https://rust-lang.github.io/rust-bindgen/requirements.html
RUN install_packages \
    build-essential \
    ca-certificates \
    clang-3.9 \
    curl \
    libclang-3.9-dev \
    libgnutls-openssl-dev \
    libssl-dev \
    llvm-3.9-dev \
  && curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUSTUP_TOOLCHAIN \
  && rustup component add \
    clippy-preview \
    rustfmt-preview \
    rust-src \
  && rm -rf /root/.cargo/registry /var/lib/apt/lists /var/cache/apt/archives
