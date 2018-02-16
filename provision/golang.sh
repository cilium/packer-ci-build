#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -E mkdir "${GOPATH}" && \
go get -u github.com/cilium/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
