#!/bin/bash

set -eux

zypper ar -r https://download.opensuse.org/repositories/Kernel:/stable/standard/Kernel:stable.repo
zypper -n --gpg-auto-import-key in --no-recommends \
        kernel-vanilla \
        kernel-vanilla-devel \
    && sudo zypper clean

update-bootloader
