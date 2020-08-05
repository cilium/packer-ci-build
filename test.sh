#!/bin/bash

set -xe

pushd ../bpf-next
sha=$(git rev-parse HEAD)
popd

pushd ../packer-ci-build
cat provision/ubuntu/kernel-next-bpftool.sh.sed | sed "s/CHECKOUT/git checkout ${sha}/" > provision/ubuntu/kernel-next-bpftool.sh
chmod +x provision/ubuntu/kernel-next-bpftool.sh

make build DISTRIBUTION=ubuntu-next
popd
