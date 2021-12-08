#!/usr/bin/env bash

set -eu

source "${ENV_FILEPATH}"
export 'IPROUTE_BRANCH'=${IPROUTE_BRANCH:-"libbpf-static-data"}
export 'IPROUTE_GIT'=${IPROUTE_GIT:-https://github.com/cilium/iproute2}
export 'LIBBPF_GIT'=${LIBBPF_GIT:-https://github.com/cilium/libbpf}
export 'GUESTADDITIONS'=${GUESTADDITIONS:-""}
export 'NETNEXT'="${NETNEXT:-false}"

# VBoxguestAdditions installation

VER="`cat ${HOME_DIR}/.vbox_version`";
ISO="VBoxGuestAdditions_$VER.iso";

# Validate that custom GuestAdditions are needed
if [[ -n "${GUESTADDITIONS}" ]]; then
    cd ${HOME_DIR}
    ISO="VBoxGuestAdditions.iso"
    wget $GUESTADDITIONS  -O $ISO
fi

mkdir -p /tmp/vbox;
mount -o loop ${HOME_DIR}/$ISO /tmp/vbox;
modprobe -r vboxguest || [[ "$NETNEXT" == "false" ]]
sh /tmp/vbox/VBoxLinuxAdditions.run
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f ${HOME_DIR}/*.iso;

if [ "${NETNEXT}" == "true" ]; then
    # Remove the binary from GuestAdditions to avoid clashing with the vboxsf
    # kernel module
    sudo rm $(which mount.vboxsf)
fi

# Disable unattended-upgrades to prevent it from holding the dpkg frontend lock
sudo systemctl disable unattended-upgrades.service
sudo systemctl stop unattended-upgrades.service

echo "Provision a new server"
sudo apt-get update
sudo apt-get install -y --allow-downgrades \
    curl jq apt-transport-https htop bmon \
    linux-tools-common linux-tools-generic \
    ca-certificates libelf-dev \
    software-properties-common \
    dh-golang devscripts fakeroot \
    dh-make libmnl-dev git \
    libdistro-info-perl libssl-dev \
    dh-systemd build-essential \
    gcc make git-buildpackage \
    pkg-config bison flex \
    zip g++ zlib1g-dev unzip python \
    libtool cmake coreutils m4 automake \
    libprotobuf-dev libyaml-cpp-dev \
    socat pv tmux bc binutils-dev \
    binutils wget rsync ifupdown \
    python3-sphinx python3-pip \
    libncurses5-dev libslang2-dev gettext \
    libselinux1-dev debhelper lsb-release \
    po-debconf autoconf autopoint moreutils \
    libseccomp2 libenchant1c2a ninja-build \
    golang-cfssl ntp \
    wireguard ipset

# Install nodejs and npm, needed for the cilium rtd sphinx theme
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=${ARCH}] https://deb.nodesource.com/node_12.x \
   $(lsb_release -cs) \
   main"
sudo apt-get update
sudo apt-get install -y nodejs

# Install protoc from github release, as protobuf-compiler version in apt is quite old (e.g 3.0.0-9.1ubuntu1)
PROTOC_ARCH="x86_64"
if [ "${ARCH}" == "arm64" ]; then
    PROTOC_ARCH="aarch_64"
fi

cd /tmp
wget -nv https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip
unzip -p protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip bin/protoc > protoc
sudo chmod +x protoc
sudo cp protoc /usr/bin
rm -rf protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip protoc

# Install nsenter for kubernetes
cd /tmp
wget -nv https://www.kernel.org/pub/linux/utils/util-linux/v2.30/util-linux-2.30.1.tar.gz
tar -xvzf util-linux-2.30.1.tar.gz
cd util-linux-2.30.1
./autogen.sh
./configure --without-python --disable-all-programs --enable-nsenter
make nsenter
sudo cp nsenter /usr/bin
cd ..
rm -fr util-linux-2.30.1/ util-linux-2.30.1.tar.gz

# Install conntrack for kubeadm >= 1.18

sudo apt-get install -y conntrack

# Documentation dependencies
sudo -H pip3 install -r https://raw.githubusercontent.com/cilium/cilium/master/Documentation/requirements.txt

# libbpf and iproute2
LINUX_ARCH="x86_64"
if [ "${ARCH}" == "arm64" ]; then
    LINUX_ARCH="aarch64"
fi

cd /tmp
git clone --depth=1 ${LIBBPF_GIT}
cd /tmp/libbpf/src
make -j "$(getconf _NPROCESSORS_ONLN)"
# By default, libbpf.so is installed to /usr/lib64 which isn't in LD_LIBRARY_PATH on Ubuntu.
# Overriding LIBDIR in addition to setting PREFIX seems to be needed due to the structure of
# libbpf's Makefile.
sudo PREFIX="/usr" LIBDIR="/usr/lib/${LINUX_ARCH}-linux-gnu" make install
sudo ldconfig
rm -rf /tmp/libbpf

cd /tmp
git clone -b ${IPROUTE_BRANCH} ${IPROUTE_GIT}
cd /tmp/iproute2
LIBBPF_FORCE="on" \
PKG_CONFIG_PATH="/usr/lib64/pkgconfig"  \
PKG_CONFIG="pkg-config --define-prefix" \
./configure
make -j `getconf _NPROCESSORS_ONLN`
make install
rm -rf /tmp/iproute2

#clean
sudo apt-get remove docker docker.io

#Add repos

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo add-apt-repository \
   "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# wget https://packages.cloud.google.com/apt/doc/apt-key.gpg
# apt-key add apt-key.gpg

#Install packages
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USERNAME}

# Install clang/llvm
# This should always converge to use the same LLVM version as in
# https://github.com/cilium/image-tools/blob/master/images/llvm/checkout-llvm.sh.
docker run --rm --name cilium-llvm -d quay.io/cilium/cilium-llvm:0147a23fdada32bd51b4f313c645bcb5fbe188d6 sleep 1000
docker cp cilium-llvm:/usr/local/bin/clang /usr/bin/clang
docker cp cilium-llvm:/usr/local/bin/llc /usr/bin/llc
docker stop cilium-llvm

#Install Golang
cd /tmp/
sudo curl -Sslk -o go.tar.gz \
    "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-${ARCH}.tar.gz"
sudo tar -C /usr/local -xzf go.tar.gz
sudo rm go.tar.gz
sudo ln -s /usr/local/go/bin/* /usr/local/bin/
go version

#ETCD installation
ETCD=etcd-${ETCD_VERSION}-linux-${ARCH}
wget -nv "https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/${ETCD}.tar.gz"
tar -xf "${ETCD}.tar.gz"
sudo mv "${ETCD}/etcd"* /usr/bin/
rm -rf "${ETCD}"*

sudo tee /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/bin/etcd --name=cilium --data-dir=/var/etcd/cilium --advertise-client-urls=http://192.168.36.11:9732 --listen-client-urls=http://0.0.0.0:9732 --listen-peer-urls=http://0.0.0.0:9733
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable etcd
sudo systemctl start etcd

# Install sonobuoy
cd /tmp
SONOBUOY=sonobuoy_${SONOBUOY_VERSION}_linux_${ARCH}.tar.gz
wget "https://github.com/heptio/sonobuoy/releases/download/v${SONOBUOY_VERSION}/${SONOBUOY}"
tar -xf "${SONOBUOY}"
sudo mv sonobuoy /usr/bin
rm -f "${SONOBUOY}"*

# Install hubble
cd /tmp
HUBBLE=hubble-linux-${ARCH}.tar.gz
wget "https://github.com/cilium/hubble/releases/download/v${HUBBLE_VERSION}/${HUBBLE}"
wget "https://github.com/cilium/hubble/releases/download/v${HUBBLE_VERSION}/${HUBBLE}.sha256sum"
sha256sum --check "${HUBBLE}".sha256sum || exit 1
sudo tar -xf "${HUBBLE}" -C /usr/bin hubble
rm -f "${HUBBLE}"*

# Clean all downloaded packages
sudo apt-get -y clean
sudo apt-get -y autoclean

# Disable systemd-resolved service
# https://github.com/cilium/cilium/issues/2750
sudo systemctl disable systemd-resolved.service
sudo service systemd-resolved stop

sudo unlink /etc/resolv.conf || true

sudo tee /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# CoreDumps https://github.com/cilium/cilium/issues/3399
sudo systemctl disable apport.service
sudo sh -c 'echo "sysctl kernel.core_pattern=/tmp/core.%e.%p.%t" > /etc/sysctl.d/66-core-pattern.conf'

# journald configuration
sudo bash -c "echo RateLimitIntervalSec=1s >> /etc/systemd/journald.conf"
sudo bash -c "echo RateLimitBurst=10000 >> /etc/systemd/journald.conf"
sudo systemctl restart systemd-journald

# Kernel parameters
sudo sh -c 'echo "kernel.randomize_va_space=0" > /etc/sysctl.d/67-randomize_va_space.conf'
