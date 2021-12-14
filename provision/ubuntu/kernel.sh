#!/usr/bin/env bash

set -e

# This script installs kernel 4.9.258 and when it finished sets the installed
# kernel as default in the grub.

mkdir /tmp/deb
cd /tmp/deb

canonicalString=${1:-0409270}
timestamp=${2:-202105261032}
subdir="${VM_ARCH}/"
headers_all_subdir="amd64/"

major=$(echo ${canonicalString:0:2} | sed 's/^0*//')
minor=$(echo ${canonicalString:2:2} | sed 's/^0*//')
micro=$(echo ${canonicalString:4} | sed 's/^0*//')

echo $major.$minor.$micro

if [[ "$major" == "5" && "$minor" == "4" ]]; then
	# Packages for this kernel are kept in the root directory
	subdir=""
	headers_all_subdir=""
fi

if [[ "$major" == "4" && "$minor" == "19" ]] || [[ "$major" == "5" && "$minor" == "4" ]] ; then
	# kernel debs have the -unsigned suffix
	imgsuffix="-unsigned"

	# module deb is provided for those kernels
	wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v$major.$minor.$micro/${subdir}linux-modules-$major.$minor.$micro-$canonicalString-generic_$major.$minor.$micro-$canonicalString.${timestamp}_${VM_ARCH}.deb
	dpkg -i *modules*.deb
fi

wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v$major.$minor.$micro/${subdir}linux-headers-$major.$minor.$micro-$canonicalString-generic_$major.$minor.$micro-$canonicalString.${timestamp}_${VM_ARCH}.deb
# _all.deb is only available in amd64
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v$major.$minor.$micro/${headers_all_subdir}linux-headers-$major.$minor.$micro-${canonicalString}_$major.$minor.$micro-${canonicalString}.${timestamp}_all.deb
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v$major.$minor.$micro/${subdir}linux-image${imgsuffix}-$major.$minor.$micro-$canonicalString-generic_$major.$minor.$micro-$canonicalString.${timestamp}_${VM_ARCH}.deb

dpkg -i *.deb

KERNEL="$major.$minor"

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
sudo reboot
