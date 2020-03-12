#!/usr/bin/env bash

set -eu

source "${ENV_FILEPATH}"
export 'IPROUTE_BRANCH'=${IPROUTE_BRANCH:-"static-data"}
export 'IPROUTE_GIT'=${IPROUTE_GIT:-https://github.com/cilium/iproute2}
export 'GUESTADDITIONS'=${GUESTADDITIONS:-""}
NETNEXT="${NETNEXT:-false}"

# VBoxguestAdditions installation

VER="`cat /home/vagrant/.vbox_version`";
ISO="VBoxGuestAdditions_$VER.iso";

# Validate that custom GuestAdditions are needed
if [[ -n "${GUESTADDITIONS}" ]]; then
    cd $HOME_DIR
    ISO="VBoxGuestAdditions.iso"
    wget $GUESTADDITIONS  -O $ISO
fi

mkdir -p /tmp/vbox;
mount -o loop ${HOME_DIR}/$ISO /tmp/vbox;
sh /tmp/vbox/VBoxLinuxAdditions.run \
    || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
    "For more read https://www.virtualbox.org/ticket/12479";
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f ${HOME_DIR}/*.iso;

if [ "${NETNEXT}" == "true" ]; then
    # Remove the binary from GuestAdditions to avoid clashing with the vboxsf
    # kernel module
    sudo rm $(which mount.vboxsf)
fi

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
    protobuf-compiler libprotobuf-dev libyaml-cpp-dev \
    socat pv tmux bc gcc-multilib binutils-dev \
    binutils wget rsync ifupdown \
    python3-sphinx python3-pip \
    libncurses5-dev libslang2-dev gettext \
    libselinux1-dev debhelper lsb-release \
    po-debconf autoconf autopoint moreutils \
    libseccomp2 libenchant1c2a ninja-build \
    golang-cfssl ntp

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

# Install clang/llvm
cd /tmp
git clone -b master https://github.com/llvm/llvm-project.git llvm
mkdir -p llvm/llvm/build/install
cd llvm
git checkout -b d941df363d1cb621a3836b909c37d79f2a3e27e2 d941df363d1cb621a3836b909c37d79f2a3e27e2
cd llvm/build
cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF" -DLLVM_ENABLE_PROJECTS="clang" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF
ninja
strip bin/clang
strip bin/llc
cp bin/clang /usr/bin/clang
cp bin/llc /usr/bin/llc
cd ../../..
rm -fr llvm/

# Documentation dependencies
sudo -H pip3 install -r https://raw.githubusercontent.com/cilium/cilium/master/Documentation/requirements.txt

#IP Route
cd /tmp
git clone -b ${IPROUTE_BRANCH} ${IPROUTE_GIT}
cd /tmp/iproute2
./configure
make -j `getconf _NPROCESSORS_ONLN`
make install

#clean
sudo apt-get remove docker docker-engine docker.io

#Add repos

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
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
sudo usermod -aG docker vagrant

#Install Golang
cd /tmp/
sudo curl -Sslk -o go.tar.gz \
    "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf go.tar.gz
sudo rm go.tar.gz
sudo ln -s /usr/local/go/bin/* /usr/local/bin/
go version

#Install docker compose
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

#ETCD installation
wget -nv "https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"
tar -xf "etcd-${ETCD_VERSION}-linux-amd64.tar.gz"
sudo mv "etcd-${ETCD_VERSION}-linux-amd64/etcd"* /usr/bin/

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
wget "https://github.com/heptio/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_linux_amd64.tar.gz"
tar -xf "sonobuoy_${SONOBUOY_VERSION}_linux_amd64.tar.gz"
sudo mv sonobuoy /usr/bin

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
