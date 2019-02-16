#!/usr/bin/env bash

set -eux

source "${ENV_FILEPATH}"

RELEASE="openSUSE_Tumbleweed"
IPROUTE2_REPO="home:joestringer:branches:security:netfilter"

zypper ar -r https://download.opensuse.org/repositories/devel:/kubic/${RELEASE}/devel:kubic.repo
zypper ar -r https://download.opensuse.org/repositories/${IPROUTE2_REPO}/${RELEASE}/${IPROUTE2_REPO}.repo
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
        iproute2-cilium -iproute2 \
        jq \
        llvm \
    && zypper clean
