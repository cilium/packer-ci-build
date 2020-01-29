#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc

git clone --branch v5.4 --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git $HOME/k

cd $HOME/k/tools/bpf/bpftool
make
sudo make install
