#!/bin/bash

set -eux

# Packer doesn't support building from an existing Vagrant box, but it supports
# building from OVF/OVA VirtualBox images. Vagrant boxes contain OVF/OVA images
# in their content. This script downloads openSUSE Vagrant box and extracts
# OVF/OVA from it.

OPENSUSE_VERSION="Tumbleweed"
ARCH="x86_64"
BOX_VERSION="1.0.6.20181025"
SHA256SUM="a60567af6e12e203e14d5882e14347e262b14dea2cc276bafefd7cb955033fec"

BOX_FILENAME="virtualbox-${BOX_VERSION}.box"
BOX_CONTENT_DIR="opensuse_base_box"

if [ ! -f ${BOX_FILENAME} ]; then
    wget -O ${BOX_FILENAME} https://vagrantcloud.com/opensuse/boxes/openSUSE-${OPENSUSE_VERSION}-${ARCH}/versions/${BOX_VERSION}/providers/virtualbox.box
fi

downloaded_sha256sum=$(sha256sum ${BOX_FILENAME})

if [[ ! $downloaded_sha256sum = *${SHA256SUM}* ]]; then
    echo "Invalid sha256 sum of the box - expected ${SHA256SUM}, got ${downloaded_sha256sum}" >&2
    exit 1
fi

mkdir -p ${BOX_CONTENT_DIR}
tar zxf ${BOX_FILENAME} -C ${BOX_CONTENT_DIR}
