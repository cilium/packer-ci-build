#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -u vagrant -E bash -c "mkdir ${GOPATH} && \
go get -u github.com/cilium/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go && \
go get -d github.com/lyft/protoc-gen-validate && \
go get github.com/subfuzion/envtpl/... && \
go get -u github.com/gordonklaus/ineffassign"

#Protoc-gen-validate installation
cd $GOPATH/src/github.com/lyft/protoc-gen-validate
sudo git checkout 4349a359d42fdfee53b85dd5c89a2f169e1dc6b2
make build

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
