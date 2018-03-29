#!/bin/bash

set -eux

# Packer doesn't support building from an existing Vagrant box, but it supports
# building from OVF/OVA VirtualBox images. Vagrant boxes contain OVF/OVA images
# in their content. This script downloads openSUSE Vagrant box and extracts
# OVF/OVA from it.

OPENSUSE_VERSION="15.0"
ARCH="x86_64"
BOX_VERSION="1.0.6.20180529"
SHA256SUM="e69815c4843b07ba227da65028e4a978af92b7e49b9ef03cae216969cb5811bd"

BOX_FILENAME="virtualbox.box"
BOX_CONTENT_DIR="opensuse_base_box"

if [ ! -f ${BOX_FILENAME} ]; then
    wget https://vagrantcloud.com/opensuse/boxes/openSUSE-${OPENSUSE_VERSION}-${ARCH}/versions/${BOX_VERSION}/providers/${BOX_FILENAME}
fi

downloaded_sha256sum=$(sha256sum ${BOX_FILENAME})

if [[ ! $downloaded_sha256sum = *${SHA256SUM}* ]]; then
    echo "Invalid sha256 sum of the box - expected ${SHA256SUM}, got ${downloaded_sha256sum}" >&2
    exit 1
fi

mkdir -p ${BOX_CONTENT_DIR}
tar zxf ${BOX_FILENAME} -C ${BOX_CONTENT_DIR}
