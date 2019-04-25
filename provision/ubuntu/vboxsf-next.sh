#!/bin/sh

set -xe

# vboxsf from the mainline is broken ("vboxsf: Unknown symbol VBoxGuestIDC (err -2)")
# on 18.04.2 and >= 5.0 kernels, thus we install from the vboxsf cleanup repo.

sudo apt-get install -y kbuild module-assistant debhelper
git clone https://github.com/jwrdegoede/vboxsf/
cd vboxsf
git checkout 87b9015c57dd7f226c768131bf8b4c0249de9835
make
sudo make modules_install
sudo depmod -a
sudo rm $(which mount.vboxsf)
