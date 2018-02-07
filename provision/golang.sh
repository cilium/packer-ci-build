#!/usr/bin/env bash

source "${ENV_FILEPATH}"

sudo -E mkdir "${GOPATH}" && \
go get -u github.com/jteeuwen/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go
