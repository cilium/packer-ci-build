#!/bin/bash

set -xe

sudo apt-get install -y --allow-downgrades \
    automake build-essential gcc

git clone --depth 1 https://github.com/HewlettPackard/netperf.git $HOME/n
cd $HOME/n/
./autogen.sh
./configure --prefix=/usr
ln -sf /bin/true /usr/bin/makeinfo
make
make install
cd -
rm -rf $HOME/n/

git clone --depth 1 https://github.com/cilium/netperf.git $HOME/n
chmod a+x $HOME/n/super_netperf
cp $HOME/n/super_netperf /usr/bin/
rm -rf $HOME/n/
