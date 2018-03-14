#!/usr/bin/env bash

set -eux

sudo zypper -n ar -r https://download.opensuse.org/repositories/home:/mrostecki:/cilium/openSUSE_Tumbleweed/home:mrostecki:cilium.repo
sudo zypper -n --gpg-auto-import-key in --no-recommends \
        bazel \
        python3-sphinx-tabs \
        python3-sphinxcontrib-openapi \
    && sudo zypper clean
