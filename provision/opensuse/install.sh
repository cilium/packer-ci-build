#!/usr/bin/env bash

set -eux

source "${ENV_FILEPATH}"

zypper ar -r https://download.opensuse.org/repositories/devel:/CaaSP:/Head:/ControllerNode/openSUSE_Leap_15.0/devel:CaaSP:Head:ControllerNode.repo
zypper ar -r https://download.opensuse.org/repositories/devel:/kubic/openSUSE_Leap_15.0/devel:kubic.repo
zypper ar -r https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.0/devel:languages:go.repo
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
