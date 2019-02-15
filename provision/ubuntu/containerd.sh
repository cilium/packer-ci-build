#!/bin/bash

source "${ENV_FILEPATH}"

set -e

wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz
sudo tar -C / -xzf cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz

cat <<EOF > /etc/containerd/config.toml
root = "/tmp/containers"
state = "/run/containerd"
oom_score = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

[debug]
  address = ""
  uid = 0
  gid = 0
  level = ""

[metrics]
  address = ""
  grpc_histogram = false
EOF

sudo systemctl enable containerd
sudo systemctl restart containerd

sudo crictl -r unix:///run/containerd/containerd.sock ps
