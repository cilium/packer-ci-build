#!/usr/bin/env bash

set -eux

source "${ENV_FILEPATH}"

zypper ar -r https://download.opensuse.org/repositories/devel:/kubic/openSUSE_Tumbleweed/devel:kubic.repo
zypper -n --gpg-auto-import-key in --no-recommends \
        autoconf \
        automake \
        bc \
        binutils \
        binutils-devel \
        bmon \
        ca-certificates-mozilla \
        clang \
        coreutils \
        cri-o \
        docker \
        docker-compose \
        etcd \
        git \
        "go${GOLANG_VERSION_MINOR}" \
        jq \
        llvm \
    && zypper clean
