# Everything the tutorial needs. Codespaces builds it, and prebuilds make that fast.
FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# Drop the base image's Yarn package source. Its signing key has expired.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk-headless cmake ninja-build libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Lingua Franca compiler, straight from its release page
RUN curl -fsSL https://github.com/lf-lang/lingua-franca/releases/download/v0.13.0/lf-cli-0.13.0-Linux-$(uname -m).tar.gz \
    | tar -xz -C /opt \
    && ln -s /opt/lf-cli-0.13.0-Linux-$(uname -m)/bin/* /usr/local/bin/

# sysmlc with Rosetta, and the Python packages that Frost and the examples use
RUN pip install --no-cache-dir \
    "sysmlc-library @ git+https://github.com/glacier-project/sysmlc-library@bd8a5da8b0794baf11a8c197660e1d794992d5d5" \
    "sysmlc @ git+https://github.com/glacier-project/sysmlc-core@69e296f74c163e58395e261742288c12ab4904cf" \
    "sysmlc-models @ git+https://github.com/glacier-project/sysmlc-models@110f133fbc266e75f32ea38eb7fca8da093c8efd" \
    "sysmlc-rosetta @ git+https://github.com/glacier-project/sysmlc-rosetta@abe91ccfc3e1d3f9ea2c712d273f8a31add54e21" \
    "machine-data-model @ git+https://github.com/glacier-project/machine-data-model@d9f2c59701502fefb5d9d0d45052c99b992a4451" \
    fmpy==0.3.32 matplotlib==3.11.2

# Frost as a Lingua Franca package, and reactor-uc, the runtime for part 05
RUN mkdir -p /opt/lf-packages \
    && git clone -q https://github.com/glacier-project/frost /opt/lf-packages/frost \
    && git -C /opt/lf-packages/frost checkout -q 56e7d787b79ecbed56444637c3f17d000bac6e12 \
    && git clone -q -b micromode https://github.com/lf-lang/reactor-uc /opt/reactor-uc \
    && git -C /opt/reactor-uc checkout -q 344d5b26a1fd090e85c49fcc224a8fb000dac619 \
    && git -C /opt/reactor-uc submodule update -q --init --recursive \
    && /opt/reactor-uc/ulf/bin/ulfc-dev --version \
    && rm -rf /root/.gradle /opt/reactor-uc/ulf/.gradle

ENV LF_PACKAGES=/opt/lf-packages \
    REACTOR_UC_PATH=/opt/reactor-uc
