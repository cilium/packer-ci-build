#!/usr/bin/env bash

# This script installs kernel 4.9.68 and when it finished sets the installed
# kernel as default in the grub.

mkdir /tmp/deb
cd /tmp/deb

wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.68/linux-image-4.9.68-040968-generic_4.9.68-040968.201712091734_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.68/linux-headers-4.9.68-040968-generic_4.9.68-040968.201712091734_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.68/linux-headers-4.9.68-040968_4.9.68-040968.201712091734_all.deb

dpkg -i *.deb



KERNEL="4.9"

function get_grub_config {
	gawk  'BEGIN {
	  l=0
	  menuindex= 1
	  stack[t=0] = 0
	}

	function push(x) { stack[t++] = x }

	function pop() { if (t > 0) { return stack[--t] } else { return "" }  }

	{

	if( $0 ~ /.*menu.*{.*/ )
	{
	  push( $0 )
	  l++;

	} else if( $0 ~ /.*{.*/ )
	{
	  push( $0 )

	} else if( $0 ~ /.*}.*/ )
	{
	  X = pop()
	  if( X ~ /.*menu.*{.*/ )
	  {
		 l--;
		 match( X, /^[^'\'']*'\''([^'\'']*)'\''.*$/, arr )

		 if( l == 0 )
		 {
		   print menuindex ": " arr[1]
		   menuindex++
		   submenu=0
		 } else
		 {
		   print "  " (menuindex-1) ">" submenu " " arr[1]
		   submenu++
		 }
	  }
	}

	}' /boot/grub/grub.cfg

}

grub_entry=$(get_grub_config | grep $KERNEL | grep -v "recovery" | awk '{ print $1 }')

echo "Default grub entry is '$grub_entry'"
grub-set-default "$grub_entry"
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/g' /etc/default/grub
update-grub
reboot
