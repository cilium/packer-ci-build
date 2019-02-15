#!/bin/sh

set -xe

# Very ugly way to compile and install vboxsf with the latest net-next ;-(

# Should go away after vboxsf has been merged upstream. Ping @brb for
# maintaining this hack.

sudo apt-get install -y kbuild module-assistant debhelper
wget https://launchpad.net/ubuntu/+archive/primary/+files/virtualbox-guest-source_6.0.4-dfsg-5_all.deb
sudo dpkg -i virtualbox-guest-source_6.0.4-dfsg-5_all.deb
cd /usr/src
sudo tar xfv virtualbox-guest.tar.bz2
cd modules/virtualbox-guest/vboxsf
sudo patch -p0 <<EOF
*** vfsmod.h
--- vfsmod.h
***************
*** 45,50 ****
--- 45,55 ----
  #include <VBox/VBoxGuestLibSharedFolders.h>
  #include "vbsfmount.h"

+ #ifndef MS_REMOUNT
+ // taken from <sys/mount.h>; including the header adds many redefinitions
+ #define MS_REMOUNT 32
+ #endif
+
  #define DIR_BUFFER_SIZE (16*_1K)

  /* per-shared folder information */
EOF
sudo make modules_install
sudo depmod $(uname -r)
