#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -u vagrant -E bash -c "mkdir ${GOPATH} && \
go get -u github.com/cilium/go-bindata/... && \
go get -u github.com/google/gops && \
go get github.com/subfuzion/envtpl/... && \
go get -u github.com/gordonklaus/ineffassign && \
go get -u github.com/heptio/sonobuoy"

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
