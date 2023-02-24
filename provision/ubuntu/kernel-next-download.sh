#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

sudo apt-get update
sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc libbfd-dev cmake libdw-dev git

# FIXME: current bpf-next kernel is failing to shut down the VM. For now to work around this, pin to
# the commit used in the last successful VM image build:
# https://jenkins.cilium.io/view/Packer%20builds/job/Vagrant-PR-Boxes-Packer-Build-Next/378/
git clone --shallow-since 2023-01-17 git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git $HOME/k
cd $HOME/k
git checkout c0f264e4edb60db410462d513e29d2de3ef7de56
git --no-pager log -n1
