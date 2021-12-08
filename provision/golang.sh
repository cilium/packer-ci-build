#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo -u ${USERNAME} -E bash -c "mkdir -p ${GOPATH} && \
go install github.com/google/gops@latest && \
go install github.com/subfuzion/envtpl/cmd/envtpl@latest && \
go install github.com/mfridman/tparse@latest"

curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo sh -s -- -b ${GOPATH}/bin/ v1.48.0

sudo -E ln -s "${GOPATH}/bin/"* /usr/bin
