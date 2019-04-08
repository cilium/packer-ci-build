#!/usr/bin/env bash

set -eux

source "${ENV_FILEPATH}"

RELEASE="openSUSE_Tumbleweed"

zypper ar -r https://download.opensuse.org/repositories/devel:/kubic/${RELEASE}/devel:kubic.repo
zypper -n --gpg-auto-import-key in --no-recommends \
        autoconf \
        automake \
        bc \
        binutils \
        binutils-devel \
        bmon \
        boringssl-devel \
        ca-certificates-mozilla \
        cilium-proxy \
        clang \
        coreutils \
        cri-o \
        docker \
        docker-compose \
        etcd \
        git \
        "go${GOLANG_VERSION_MINOR}" \
        iproute2 \
        jq \
        llvm \
    && zypper clean

# Disable Envoy installation from Docker image. It's linked agains a different
# version of glibc. For openSUSE we install Envoy from packages.
echo "export DISABLE_ENVOY_INSTALLATION=1" >> /home/vagrant/.bashrc
