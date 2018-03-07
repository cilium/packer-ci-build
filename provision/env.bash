#!/usr/bin/env bash

export GOLANG_VERSION="1.9.3"
export ETCD_VERSION="v3.1.0"
export DOCKER_COMPOSE_VERSION="1.16.1"
export BAZEL_VERSION="0.11.0"

export CLANG_ROOT=/usr/local/clang
export HOME_DIR=/home/vagrant
export HOME=/home/vagrant
export GOPATH="${HOME}/go"
export PATH="${GOPATH}/bin:${CLANG_ROOT}/bin:$PATH"
