#!/usr/bin/env bash

set -eux

zypper -n ar -r https://download.opensuse.org/repositories/devel:/CaaSP:/Head:/ControllerNode/openSUSE_Leap_15.0/devel:CaaSP:Head:ControllerNode.repo
zypper -n ar -r https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.0/devel:languages:go.repo
zypper -n ar -r https://download.opensuse.org/repositories/devel:/libraries:/c_c++/openSUSE_Leap_15.0/devel:libraries:c_c++.repo
zypper -n ar -r https://download.opensuse.org/repositories/home:/mrostecki:/branches:/devel:/libraries:/c_c++/openSUSE_Leap_15.0/home:mrostecki:branches:devel:libraries:c_c++.repo
zypper -n --gpg-auto-import-key ref

zypper -n up --replacefiles
zypper -n dup --replacefiles
zypper -n --gpg-auto-import-key in --no-recommends \
        autoconf \
        automake \
        bazel \
        bc \
        binutils-devel \
        bison \
        bmon \
        c-ares-devel-static \
        ca-certificates-mozilla \
        clang \
        cmake \
        coreutils \
        cri-o \
        curl \
        devscripts \
        dh-make \
        dhcp \
        dhcp-client \
        docker \
        docker-compose \
        envtpl \
        etcd \
        fakeroot \
        flex \
        gcc \
        gcc-32bit \
        gcc-c++ \
        gcc-c++-32bit \
        gettext-runtime \
        gettext-tools \
        git \
        glibc-devel \
        glibc-devel-32bit \
        go1.10 \
        golang-github-jteeuwen-go-bindata \
        gops \
        gperftools-devel-static \
        htop \
        ineffassign \
        iproute2 \
        jq \
        kubecfg \
        less \
        libcares2 \
        libelf-devel \
        libevent-devel-static \
        libluajit-5_1-2 \
        libmnl-devel \
        ncurses5-devel \
        libnghttp2-devel-static \
        libopenssl-devel \
        libprotobuf-c-devel \
        libselinux-devel \
        libslang2 \
        libtool \
        libyaml-cpp0_6 \
        libyaml-devel \
        libz1 \
        llvm \
        lsb \
        lsb-release \
        lua51-luajit \
        lua51-luajit-devel \
        m4 \
        make \
        ninja \
        protobuf-c \
        protobuf-devel \
        protoc-gen-go \
        protoc-gen-validate \
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
    && zypper clean

reboot
