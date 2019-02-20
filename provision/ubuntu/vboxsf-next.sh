#!/bin/sh

set -xe

# vboxsf from the mainline is broken ("vboxsf: Unknown symbol VBoxGuestIDC (err -2)")
# on 18.04.2 and >= 5.0 kernels, thus we install from the vboxsf cleanup repo.

sudo apt-get install -y kbuild module-assistant debhelper
git clone https://github.com/jwrdegoede/vboxsf/
cd vboxsf
git checkout fb360320b7d5c2dc74cb958c9b27e8708c1c9bc2
make
sudo make modules_install
sudo depmod -a
sudo rm $(which mount.vboxsf)
