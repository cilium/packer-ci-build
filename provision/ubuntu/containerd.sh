#!/bin/bash

source "${ENV_FILEPATH}"

set -e

CONTAINERD_TARGZ=cri-containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz

wget https://storage.googleapis.com/cri-containerd-release/${CONTAINERD_TARGZ}
sudo tar -C / -xzf ${CONTAINERD_TARGZ}
rm ${CONTAINERD_TARGZ}

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

sudo systemctl restart docker
sudo docker ps
