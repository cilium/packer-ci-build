#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

cd /tmp/

export CONTAINERD_VERSION="1.1.0"

wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz
sudo tar -C / -xzf cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz
sudo systemctl enable containerd
