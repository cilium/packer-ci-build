#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc libbfd-dev

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git $HOME/k
cd $HOME/k
git --no-pager log -n1
