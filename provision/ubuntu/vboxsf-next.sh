#!/bin/sh

set -xe

# vboxsf from the mainline is broken ("vboxsf: Unknown symbol VBoxGuestIDC (err -2)")
# on 18.04.3 and >= 5.0 kernels, thus we install from the vboxsf cleanup repo.

sudo apt-get install -y kbuild module-assistant debhelper
git clone https://github.com/jwrdegoede/vboxsf/
cd vboxsf
git checkout 5aba938bcabd978e4615186ad7d8617d633e6f30
make
sudo make modules_install
sudo depmod -a
sudo rm $(which mount.vboxsf)
