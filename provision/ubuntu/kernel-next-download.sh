#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc libbfd-dev cmake libdw-dev git

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git $HOME/k
cd $HOME/k
git --no-pager log -n1
# We need this commit to fix a regression in perf's build.
git remote add tip https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git
git fetch tip
git config --global user.email "maintainer@cilium.io"
git config --global user.name "Cilium Maintainers"
git cherry-pick d4ff92659244a4783e424fa41b6f83645d8920c1
