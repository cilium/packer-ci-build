#!/bin/bash

set -eu

mkdir -p /var/etcd/cilium
chown -R etcd:etcd /var/etcd/cilium

sudo sed -i 's+ETCD_DATA_DIR=.*$+ETCD_DATA_DIR=/var/etcd/cilium+g' /etc/sysconfig/etcd
sudo sed -i 's+ETCD_LISTEN_CLIENT_URLS=.*$+ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:9732"+g' /etc/sysconfig/etcd
sudo sed -i 's+#ETCD_LISTEN_PEER_URLS=.*$+ETCD_LISTEN_PEER_URLS="http://0.0.0.0:9733"+g' /etc/sysconfig/etcd
sudo sed -i 's+#ETCD_INITIAL_ADVERTISE_PEER_URLS=.*$+ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:9733"+g' /etc/sysconfig/etcd
sudo sed -i 's+#ETCD_INITIAL_CLUSTER=.*$+ETCD_INITIAL_CLUSTER="default=http://localhost:9733"+g' /etc/sysconfig/etcd
sudo sed -i 's+ETCD_ADVERTISE_CLIENT_URLS=.*$+ETCD_ADVERTISE_CLIENT_URLS="http://localhost:9732"+g' /etc/sysconfig/etcd

sudo systemctl enable etcd
sudo systemctl start etcd
