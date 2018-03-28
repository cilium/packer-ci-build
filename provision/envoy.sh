#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -E mkdir -p "${GOPATH}/src/github.com/cilium"
sudo -E chmod 755 "${GOPATH}/src/github.com/cilium"
sudo -E chown vagrant:vagrant "${GOPATH}" -R

sudo -u vagrant -E sh -c "\
    cd \"${GOPATH}/src/github.com/cilium\" && \
    git clone -b envoy-integrate-logs https://github.com/cilium/cilium.git && \
    cd cilium && \
    git submodule update --init --recursive && \
    cd envoy && \
    grep \"ENVOY_SHA[ \t]*=\" WORKSPACE | cut -d \\\" -f 2 >SOURCE_VERSION && \
    cat SOURCE_VERSION && \
    make && \
    make PKG_BUILD=1"

sudo rm -fr "${GOPATH}/src/github.com/cilium"

sudo rm -rf /usr/bin/cilium* /opt/cni/bin/cilium-cni "${GOPATH}/pkg/linux_amd64/github.com/cilium"
