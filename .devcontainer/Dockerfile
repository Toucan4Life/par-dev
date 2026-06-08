FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=node

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libasound2-dev \
        libgl1-mesa-dev \
        libgtk-3-dev \
        libssl-dev \
        libudev-dev \
        libwayland-dev \
        libx11-dev \
        libxcb-render0-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
        libxkbcommon-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

ENV CARGO_HOME=/home/${USERNAME}/.cargo \
    RUSTUP_HOME=/home/${USERNAME}/.rustup \
    PATH=/home/${USERNAME}/.cargo/bin:${PATH}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | bash -s -- -y --profile default --default-toolchain stable \
    && rustup component add clippy rustfmt rust-src