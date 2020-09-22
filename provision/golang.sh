#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -u vagrant -E bash -c "mkdir ${GOPATH} && \
go get -u github.com/google/gops && \
go get github.com/subfuzion/envtpl/... "

curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo sh -s -- -b ${GOPATH}/bin/ v1.31.0

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
