#!/bin/bash

set -xe

export 'KCONFIG'=${KCONFIG:-"config-`uname -r`"}

cd $HOME/k

sudo apt-get update
sudo apt-get install -y --allow-downgrades \
	cmake libdw-dev git

# Build pahole
PaholeVer="1.20"
git clone git://git.kernel.org/pub/scm/devel/pahole/pahole.git
pushd pahole
git checkout -b v${PaholeVer} v${PaholeVer}

mkdir build
pushd build
cmake -D__LIB=lib ..
sudo make install
popd
popd
# must remove pahole to avoid dpkg errors
rm -rf pahole

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

# Build kernel
cp /boot/config-`uname -r` .config
make oldconfig && make prepare

./scripts/config --disable CONFIG_WERROR
./scripts/config --module CONFIG_VBOXGUEST
./scripts/config --enable CONFIG_DEBUG_INFO
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
./scripts/config --enable CONFIG_VBOXSF_FS
./scripts/config --module CONFIG_WIREGUARD
./scripts/config --enable CONFIG_DEBUG_INFO_BTF

make -j$(nproc) deb-pkg
cd ..
# remove repo before installation to avoid "no space left on device" errors
rm -r $HOME/k

sudo dpkg -i linux-*.deb
rm linux-*.deb
rm $HOME/linux-*
sudo ln -sf /boot/System.map-$(uname -r) /boot/System.map

sudo reboot
