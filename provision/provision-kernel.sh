#!/usr/bin/env bash

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export VM_ARCH=${VM_ARCH:-amd64}

set -e

sudo -E ${dir}/ubuntu/netperf.sh
sudo -E ${dir}/ubuntu/kernel-next-download.sh
if [ -n "${NETNEXT}" ]; then
    sudo -E ${dir}/ubuntu/kernel-next-tools.sh
    sudo -E ${dir}/ubuntu/kernel-next.sh
elif [ -n "${KERNEL}" ]; then
    sudo -E ${dir}/ubuntu/kernel.sh ${KERNEL} ${KERNEL_DATE}
else
    echo "*** KEEPING KERNEL $(uname -r) ***"
fi
