#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

cd $HOME/k

cp /boot/config-`uname -r` .config
make oldconfig && make prepare

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
./scripts/config --module CONFIG_TLS
./scripts/config --disable CONFIG_OVERLAY_FS_INDEX

sudo make -j$(nproc) deb-pkg
cd ..
sudo dpkg -i linux-*.deb
sudo ln -sf /boot/System.map-$(uname -r) /boot/System.map

sudo reboot
