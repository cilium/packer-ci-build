#!/usr/bin/env bash

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export ENV_FILEPATH=${ENV_FILEPATH:-"${dir}/env.bash"}
export VM_ARCH=${VM_ARCH:-amd64}
export USERNAME=${USERNAME:-vagrant}
export NETNEXT=${NETNEXT:-false}
source "${ENV_FILEPATH}"

set -e

sudo -E ${dir}/ubuntu/kernel-next-clean.sh
sudo -E ${dir}/vagrant.sh
sudo -E ${dir}/ubuntu/install.sh
sudo -E ${dir}/golang.sh
sudo -E ${dir}/swap.sh
sudo -E ${dir}/registry.sh
sudo -E ${dir}/ubuntu/crio.sh
sudo -E ${dir}/ubuntu/containerd.sh
sudo -E ${dir}/kind.sh
if [ -n "$PULL_IMAGES" ]; then
    sudo -E ${dir}/pull-images.sh
fi
sudo -E ${dir}/fix-home-ownership.sh

echo "*******************************************"
echo "*** PROVISIONING SUCCESSFULLY COMPLETED ***"
echo "*******************************************"
