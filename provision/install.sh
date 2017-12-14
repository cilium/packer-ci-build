#!/bin/bash

GOLANG_VERSION="1.8.3"
ETCD_VERSION="v3.1.0"
CERTS_DIR=/certs/

#If VBOX server
VER="`cat /home/vagrant/.vbox_version`";
ISO="VBoxGuestAdditions_$VER.iso";
mkdir -p /tmp/vbox;
mount -o loop $HOME_DIR/$ISO /tmp/vbox;
sh /tmp/vbox/VBoxLinuxAdditions.run \
    || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
    "For more read https://www.virtualbox.org/ticket/12479";
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f $HOME_DIR/*.iso;


echo "Provision a new server"
sudo apt-get update
sudo apt-get install -y --allow-downgrades \
    curl jq apt-transport-https htop bmon \
    linux-tools-common linux-tools-generic \
    ca-certificates \
    software-properties-common \
    dh-golang devscripts fakeroot \
    dh-make clang git \
    libdistro-info-perl \
    dh-systemd build-essential \
    llvm gcc make libc6-dev.i386 git-buildpackage \
    pkg-config bison flex

#IP Route
cd /tmp && \
git clone -b v4.10.0 git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git && \
cd /tmp/iproute2 && \
./configure && \
make -j `getconf _NPROCESSORS_ONLN` && \
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

#Install Golang
cd /tmp/
sudo curl -Sslk -o go.tar.gz \
    "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz" && \
sudo tar -C /usr/local -xzf go.tar.gz && \
sudo rm go.tar.gz && \
sudo ln -s /usr/local/go/bin/* /usr/local/bin/ && \
go version &&\
sudo mkdir /go/ &&\
export GOPATH=/go/ &&\
go get -u github.com/jteeuwen/go-bindata/... && \
go get -u github.com/google/gops && \
sudo ln -sf /go/bin/* /usr/local/bin/

#Install docker compose
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

#ETCD installation
wget -nv https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -xf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
sudo mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/bin/

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

#Docker registry - certs

sudo mkdir -p $CERTS_DIR
sudo chmod 777 $CERTS_DIR
cd $HOME
rm -rfv certs
mkdir certs

cat <<EOF > server.conf
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
C                      = UK
ST                     = UK
L                      = London
O                      = cilium
OU                     = experimental
CN                     = cilium.io
emailAddress           = ian@cilium.io

[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = cilium.io
DNS.2 = *.cilium.io
DNS.3 = k8s1
IP.1 = 192.168.36.11
IP.2 = 10.0.2.15
EOF

openssl genrsa -out certs/ca.key 4096
openssl req -new -x509 -days 3650 -key certs/ca.key -out certs/ca.crt \
    -subj "/C=uk/ST=uk/L=London/O=cilium/CN=cilium.io"

openssl genrsa -out certs/cilium.key 4096
openssl req -new -nodes \
    -key certs/cilium.key \
    -out certs/cilium.request -config server.conf

openssl x509 -req -days 366 \
    -in certs/cilium.request \
    -CA certs/ca.crt \
    -CAkey certs/ca.key \
    -set_serial 01 \
    -out certs/cilium.cert \
    -extensions v3_req -extfile server.conf


cp -rfv certs/* /certs/
cp certs/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

docker run -d -p 5000:5000 --name registry -v ${CERTS_DIR}:/certs \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cilium.cert \
        -e REGISTRY_HTTP_TLS_KEY=/certs/cilium.key \
        --restart=always \
        registry:2
