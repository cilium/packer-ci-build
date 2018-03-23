#!/bin/bash

set -xe

export 'IPROUTE_BRANCH'=${IPROUTE_BRANCH:-"net-next"}
export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}


sudo apt-get install -y --allow-downgrades \
    pkg-config bison flex build-essential gcc libssl-dev \
    libelf-dev bc

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git $HOME/k
cd $HOME/k

# This patches fixes some issues with Vboxguest/VboxSF. Need to be removed when are merged.
# curl https://patchwork.kernel.org/patch/10216607/raw/ -o vboxfs_patch
# git apply  vboxfs_patch

# curl https://patchwork.kernel.org/patch/10315021/raw/ -o vguest_patch_1
# curl https://patchwork.kernel.org/patch/10315017/raw/ -o vguest_patch_2

# git apply vguest_patch_1
# git apply vguest_patch_2

cp /boot/config-`uname -r` .config
make oldconfig && make prepare

./scripts/config --module CONFIG_VBOXSF_FS
./scripts/config --module CONFIG_VBOXGUEST
./scripts/config --disable CONFIG_DEBUG_INFO
./scripts/config --disable CONFIG_DEBUG_KERNEL
./scripts/config --enable CONFIG_BPF
./scripts/config --enable CONFIG_BPF_SYSCALL
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_BPF
./scripts/config --module CONFIG_NET_CLS_BPF
./scripts/config --module CONFIG_NET_ACT_BPF
./scripts/config --enable CONFIG_BPF_JIT
./scripts/config --enable CONFIG_HAVE_BPF_JIT
./scripts/config --enable CONFIG_BPF_EVENTS
./scripts/config --enable BPF_STREAM_PARSER
./scripts/config --module CONFIG_TEST_BPF
./scripts/config --disable CONFIG_LUSTRE_FS
./scripts/config --enable CONFIG_CGROUP_BPF
./scripts/config --module CONFIG_NET_SCH_INGRESS
./scripts/config --enable CONFIG_NET_CLS_ACT
./scripts/config --enable CONFIG_LWTUNNEL_BPF
./scripts/config --enable CONFIG_HAVE_EBPF_JIT
./scripts/config --module CONFIG_NETDEVSIM


sudo make deb-pkg
cd ..
sudo dpkg -i linux-*.deb
