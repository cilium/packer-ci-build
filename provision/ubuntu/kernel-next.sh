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

# Apply local patches
git config --global user.email "maintainer@cilium.io"
git config --global user.name  "Cilium Maintainers"
git am /tmp/*.patch

# Build kernel
cp /boot/config-`uname -r` .config
yes "" | make localyesconfig && make prepare

./scripts/config --enable CONFIG_LOCALVERSION_AUTO
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
./scripts/config --enable CONFIG_DEBUG_INFO_BTF_MODULES
./scripts/config --disable CONFIG_SYSTEM_TRUSTED_KEYS
./scripts/config --disable CONFIG_SYSTEM_REVOCATION_KEYS
./scripts/config --enable CONFIG_VIRTIO_NET
# Needed by VirtualBox to load the Guest Additions.
./scripts/config --enable CONFIG_ISO9660_FS
# Needed for Docker.
./scripts/config --enable CONFIG_VETH
./scripts/config --enable CONFIG_BRIDGE
./scripts/config --module CONFIG_BRIDGE_NETFILTER
./scripts/config --module CONFIG_IP_NF_FILTER
./scripts/config --module CONFIG_IP_NF_TARGET_MASQUERADE
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNTRACK
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_IPVS
./scripts/config --enable CONFIG_NETFILTER_ADVANCED
./scripts/config --enable CONFIG_NF_CONNTRACK
./scripts/config --enable CONFIG_IP_VS
./scripts/config --module CONFIG_NETFILTER_XT_MARK
./scripts/config --module CONFIG_IP_NF_NAT
./scripts/config --module CONFIG_NF_NAT
./scripts/config --enable CONFIG_DM_THIN_PROVISIONING
# Needed for Kubernetes.
./scripts/config --module CONFIG_IP_NF_TARGET_REDIRECT
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_COMMENT
# Needed for Cilium.
./scripts/config --enable CONFIG_IP_NF_MANGLE
./scripts/config --enable CONFIG_IP_NF_RAW
./scripts/config --enable CONFIG_IP6_NF_IPTABLES
./scripts/config --enable CONFIG_IP6_NF_FILTER
./scripts/config --enable CONFIG_IP6_NF_MANGLE
./scripts/config --enable CONFIG_IP6_NF_RAW
./scripts/config --enable CONFIG_IP6_NF_NAT
./scripts/config --enable CONFIG_IP6_NF_TARGET_MASQUERADE
./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TPROXY
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_MARK
./scripts/config --module CONFIG_NETFILTER_XT_MATCH_SOCKET
./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CT
./scripts/config --module CONFIG_IP_SET
./scripts/config --module CONFIG_IP_SET_HASH_IP
./scripts/config --module CONFIG_NETFILTER_XT_SET
./scripts/config --module CONFIG_VXLAN
./scripts/config --module CONFIG_GENEVE
./scripts/config --module CONFIG_NET_SCH_FQ
# Needed for Cilium's IPsec implementation.
./scripts/config --enable CONFIG_XFRM
./scripts/config --enable CONFIG_XFRM_OFFLOAD
./scripts/config --enable CONFIG_XFRM_STATISTICS
./scripts/config --module CONFIG_XFRM_ALGO
./scripts/config --module CONFIG_XFRM_USER
./scripts/config --module CONFIG_INET_ESP
./scripts/config --module CONFIG_INET_IPCOMP
./scripts/config --module CONFIG_INET_XFRM_TUNNEL
./scripts/config --module CONFIG_INET_TUNNEL
./scripts/config --module CONFIG_INET6_ESP
./scripts/config --module CONFIG_INET6_IPCOMP
./scripts/config --module CONFIG_INET6_XFRM_TUNNEL
./scripts/config --module CONFIG_INET6_TUNNEL
./scripts/config --module CONFIG_INET_XFRM_MODE_TUNNEL
./scripts/config --module CONFIG_CRYPTO_AEAD
./scripts/config --module CONFIG_CRYPTO_AEAD2
./scripts/config --module CONFIG_CRYPTO_GCM
./scripts/config --module CONFIG_CRYPTO_SEQIV
./scripts/config --module CONFIG_CRYPTO_CBC
./scripts/config --module CONFIG_CRYPTO_HMAC
./scripts/config --module CONFIG_CRYPTO_SHA256
./scripts/config --module CONFIG_CRYPTO_AES
# Needed for Cilium's tests.
./scripts/config --module CONFIG_NF_CT_NETLINK
./scripts/config --module CONFIG_DUMMY
./scripts/config --module CONFIG_BONDING
./scripts/config --module CONFIG_VLAN_8021Q
# Needed for NFS shared folders.
./scripts/config --module CONFIG_NFS_FS
./scripts/config --module CONFIG_NFS_V3
./scripts/config --module CONFIG_NFSD
./scripts/config --enable CONFIG_NFSD_V3

yes "" | make config
make -j$(nproc) deb-pkg
cd ..
# remove repo before installation to avoid "no space left on device" errors
rm -r $HOME/k

sudo dpkg -i linux-*.deb
rm linux-*.deb
rm $HOME/linux-*
sudo ln -sf /boot/System.map-$(uname -r) /boot/System.map

sudo reboot
