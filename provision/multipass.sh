#!/usr/bin/env bash

set -eux

continue=false
purge=false
while getopts cf flag
do
    case "${flag}" in
	c) continue=true;;
        f) purge=true;;
    esac
done
shift $(($OPTIND - 1))

# check that VM name is given as a positional argument
if [ -z "${1-}" ]; then
    echo "Usage: $0 [-f] [-c] <VM-name>"
    echo "following environment variables are honored: MOUNT, KERNEL, KERNEL_DATE, NETNEXT, PULL_IMAGES, UBUNTU, VM_CPUS, VM_MEMORY, VM_DISK, VM_USERNAME, HOST_IP, HOST_NETWORK, HOST_MASK, LOG"
    exit 1
fi
VM_NAME=$1

# Mount using NFS by default since it is the fastest mount option on macOS,
# other options are 'native' (p9 on multipass 1.11 on macOS) and 'default' (sshfs)
MOUNT=${MOUNT:-NFS}
case "$MOUNT" in
    NFS) ;;
    native) ;;
    default) ;;
    *)
	echo "unsupported MOUNT type, use NFS, native, or default"
	exit 1
	;;
esac

KERNEL=${KERNEL:-}
KERNEL_DATE=${KERNEL_DATE:-}
NETNEXT=${NETNEXT:-}
PULL_IMAGES=${PULL_IMAGES:-}

UBUNTU=${UBUNTU:-22.04}
VM_CPUS=${VM_CPUS:-4}
VM_MEMORY=${VM_MEMORY:-4G}
VM_DISK=${VM_DISK:-40G}
VM_ARCH=$(uname -m)
VM_ARCH=${VM_ARCH/x86_64/amd64}
VM_ARCH=${VM_ARCH/aarch64/arm64}
VM_USERNAME=${VM_USERNAME:-ubuntu}
HOST_IP=${HOST_IP:-192.168.64.1}

HOST_NETWORK=${HOST_NETWORK:-${HOST_IP%.*}.0}
HOST_MASK=${HOST_MASK:-255.255.255.0}

LOG=/tmp/$VM_NAME-provision.log

# Share parent if it is named "cilium", so that it can be correctly mounted
# as ~/go/src/github.com/cilium"
parent=$(cd "$(dirname $PWD)"; pwd -P)
if [ "$(basename $parent)" = "cilium" ]; then
    SHARE_SOURCE=$(dirname $parent)
    SHARE_TARGET=/home/$VM_USERNAME/go/src/github.com
else
    SHARE_SOURCE=$parent
    SHARE_TARGET=/home/$VM_USERNAME/go/src/github.com/cilium
fi

function copy_provision {
    multipass transfer --recursive --parents provision $VM_NAME:/tmp/provision
    multipass exec $VM_NAME -- bash -c "chmod +x /tmp/provision/*.sh /tmp/provision/ubuntu/*.sh"
}

function nfs_export {
    ETC_EXPORTS="$SHARE_SOURCE -mapall=$(whoami) -alldirs -network $HOST_NETWORK -mask $HOST_MASK"

    if ! grep "$ETC_EXPORTS" /etc/exports; then
	echo "Adding entry to /etc/exports, sudo password may be needed."
	sudo sh -c "echo >> /etc/exports \"$ETC_EXPORTS\""
	if [ -f `which nfsd` ]; then
	    sudo nfsd restart
	fi
    else
	echo /etc/exports already has line with "$ETC_EXPORTS"
    fi
}

if [ $purge == "true" ]; then
    multipass delete $VM_NAME --purge
fi

if ! multipass info $VM_NAME 2>&1 >/dev/null; then
    echo "Launching $VM_NAME"
    rm -f $LOG

    cp user-data.yaml /tmp
    if [ -f ~/.ssh/id_rsa.pub ]; then
	printf "\nssh_authorized_keys:\n  - " >> /tmp/user-data.yaml
	cat ~/.ssh/id_rsa.pub >> /tmp/user-data.yaml
    fi
    multipass launch -vvvv --disk $VM_DISK --cloud-init /tmp/user-data.yaml --cpus $VM_CPUS --memory $VM_MEMORY --name $VM_NAME $UBUNTU
    echo "Launched multipass VM \"$VM_NAME\", use \"multipass delete $VM_NAME --purge\" to delete it."
elif [ $continue == "false" ]; then
    echo "$VM_NAME already exists, specify -c to use it or -f to delete it."
    exit 1
fi

#
# Configure kernel if not already done
#
if ! tail $LOG | grep -e "Rebooting kernel" -e "KEEPING KERNEL"; then
    copy_provision
    multipass exec $VM_NAME -- bash -c "VM_ARCH=$VM_ARCH KERNEL=$KERNEL KERNEL_DATE=$KERNEL_DATE NETNEXT=$NETNEXT /tmp/provision/provision-kernel.sh 2>&1 || true" | tee $LOG
    if tail $LOG | grep "Rebooting kernel"; then
	echo "Waiting until kernel reboots"
	until multipass exec $VM_NAME -- uname -a; do
	    sleep 5
	done
	echo "Resuming provisioning..."
    elif ! tail $LOG | grep "KEEPING KERNEL"; then
	echo "*** Kernel provisioning failed, see $LOG ***"
	exit 1
    fi
fi

#
# Continue provisioning if not already done
#
if ! tail $LOG | grep "PROVISIONING SUCCESSFULLY COMPLETED"; then
    copy_provision
    multipass exec $VM_NAME -- bash -c "NETNEXT=$NETNEXT VM_ARCH=$VM_ARCH USERNAME=$VM_USERNAME PULL_IMAGES=$PULL_IMAGES /tmp/provision/provision.sh 2>&1" | tee -a $LOG
    #
    # Fail if not successfully completed
    #
    tail $LOG | grep "PROVISIONING SUCCESSFULLY COMPLETED"
fi

#
# Add mount to Cilium directory.
#
if [ "$MOUNT" = "NFS" ]; then
    nfs_export
    multipass exec $VM_NAME -- mkdir -p $SHARE_TARGET
    multipass exec $VM_NAME -- sudo bash -c "echo \"$HOST_IP:$SHARE_SOURCE	$SHARE_TARGET	nfs	defaults	0	0\" >>/etc/fstab && mount -a"
elif [ "$MOUNT" = "native" ]; then
    multipass stop $VM_NAME
    multipass mount -t native $SHARE_SOURCE $VM_NAME:$SHARE_TARGET
    multipass start $VM_NAME
else # the default case
    multipass mount $SHARE_SOURCE $VM_NAME:$SHARE_TARGET
fi

#
# Verify that the mount works
#
multipass exec $VM_NAME -- cat /home/$VM_USERNAME/go/src/github.com/cilium/cilium/VERSION

#
# Remove provisioning artifacts last so that we keep them when provisioning fails
#
rm -f /tmp/user-data.yaml || true
rm -f $LOG || true
multipass exec $VM_NAME -- rm -rf /tmp/provision || true
