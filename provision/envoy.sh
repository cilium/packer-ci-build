#!/bin/bash

export GOPATH=/go/
export GOROOT=/usr/local/go
export CILIUM_USE_ENVOY=1
export HOME_DIR=/home/vagrant
export HOME=/home/vagrant
export BAZEL_VERSION="0.8.1"

NEWPATH="$GOROOT/bin:$GOPATH/bin:$CLANGROOT/bin"
export PATH="$NEWPATH:$PATH"

wget -nv https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
chmod +x bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
sudo -E ./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
sudo -E mv /usr/local/bin/bazel /usr/bin
rm bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh

mkdir -p $GOPATH/src/github.com/cilium/
chmod 777 $GOPATH/src/github.com/cilium/

sudo -u vagrant -E sh -c "\
    cd $GOPATH/src/github.com/cilium/ && \
    git clone -b master https://github.com/cilium/cilium.git && \
    cd cilium && \
    git submodule update --init --recursive && \
    cd envoy/ && \
    grep \"ENVOY_SHA[ \t]*=\" WORKSPACE | cut -d \\\" -f 2 >SOURCE_VERSION && \
    cat SOURCE_VERSION && \
    make PKG_BUILD=1 CILIUM_USE_ENVOY=1"
