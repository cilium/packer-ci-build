#!/bin/bash

export HOME_DIR=/home/vagrant
export HOME=/home/vagrant
export GOPATH="${HOME}/go"
export BAZEL_VERSION="0.8.1"

export PATH="${GOPATH}/bin:$CLANGROOT/bin:$PATH"

wget -nv https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
chmod +x bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
sudo -E ./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
sudo -E mv /usr/local/bin/bazel /usr/bin
rm bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh

sudo -E mkdir -p "${GOPATH}/src/github.com/cilium"
sudo -E chmod 755 "${GOPATH}/src/github.com/cilium"
sudo -E chown vagrant:vagrant "${GOPATH}" -R

sudo -u vagrant -E sh -c "\
    cd \"${GOPATH}/src/github.com/cilium\" && \
    git clone -b master https://github.com/cilium/cilium.git && \
    cd cilium && \
    git submodule update --init --recursive && \
    cd envoy && \
    grep \"ENVOY_SHA[ \t]*=\" WORKSPACE | cut -d \\\" -f 2 >SOURCE_VERSION && \
    cat SOURCE_VERSION && \
    make && \
    make PKG_BUILD=1"

sudo rm -fr "${GOPATH}/src/github.com/cilium"
