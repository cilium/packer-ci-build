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
        bpftool \
        ca-certificates-mozilla \
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
