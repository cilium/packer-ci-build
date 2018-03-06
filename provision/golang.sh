#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -E mkdir "${GOPATH}" && \
go get -u github.com/cilium/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go && \
go get -u github.com/lyft/protoc-gen-validate

#Protoc-gen-validate installation
cd $GOPATH/src/github.com/lyft/protoc-gen-validate
sudo git checkout 930a67cf7ba41b9d9436ad7a1be70a5d5ff6e1fc
make build

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
