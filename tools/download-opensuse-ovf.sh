#!/bin/bash

set -eux

# Packer doesn't support building from an existing Vagrant box, but it supports
# building from OVF/OVA VirtualBox images. Vagrant boxes contain OVF/OVA images
# in their content. This script downloads openSUSE Vagrant box and extracts
# OVF/OVA from it.

OPENSUSE_VERSION="42.3"
ARCH="x86_64"
BOX_VERSION=1.0.5.20171128
SHA256SUM="5c1c8f4420330816da4b856996b20f915bf2aa01e95797bed912cda1b2bdda15"

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
