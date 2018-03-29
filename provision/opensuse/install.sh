#!/usr/bin/env bash

set -eux

sudo zypper -n ar -r https://download.opensuse.org/repositories/home:/mrostecki:/cilium/openSUSE_Leap_42.3/home:mrostecki:cilium.repo
sudo zypper -n ar -r https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_42.3/devel:languages:go.repo
sudo zypper -n --gpg-auto-import-key in --no-recommends \
        autoconf \
        automake \
        bazel \
        bc \
        binutils \
        binutils-devel \
        bison \
        bmon \
        ca-certificates-mozilla \
        clang \
        cmake \
        coreutils \
        curl \
        devscripts \
        dh-make \
        dhcp \
        dhcp-client \
        docker \
        docker-compose \
        etcd \
        fakeroot \
        flex \
        gcc7 \
        gcc7-32bit \
        gcc7-c++ \
        gcc7-c++-32bit \
        gettext-runtime \
        gettext-tools \
        git \
        glibc-devel \
        glibc-devel-32bit \
        go1.9 \
        htop \
        iproute2 \
        jq \
        less \
        libelf-devel \
        libmnl-devel \
        ncurses-devel \
        libopenssl-devel \
        libprotobuf-c-devel \
        libprotobuf-c1 \
        libselinux-devel \
        libtool \
        libyaml-devel \
        llvm \
        lsb \
        lsb-release \
        m4 \
        make \
        protobuf-c \
        protobuf-devel \
        pv \
        python-devel \
        python-xml \
        python3 \
        python3-devel \
        python3-pip \
        python3-recommonmark \
        python3-Sphinx \
        python3-sphinx-tabs \
        python3-sphinxcontrib-httpdomain \
        python3-sphinxcontrib-openapi \
        rsync \
        slang-devel \
        socat \
        sudo \
        tmux \
        unzip \
        util-linux \
        vim \
        wget \
        zip \
        zlib-devel \
    && sudo zypper clean

sudo update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-7 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7
