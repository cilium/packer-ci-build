#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo apt-key adv --recv-key --keyserver keyserver.ubuntu.com 8BECF1637AD8C79D

cat <<EOF > /etc/apt/sources.list.d/projectatomic-ubuntu-ppa-xenial.list
deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu xenial main
EOF

sudo apt-get update
sudo apt-get install -y cri-o-1.10
