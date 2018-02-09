#!/usr/bin/env bash

set -eux

sudo zypper -n ar -r https://download.opensuse.org/repositories/home:/mrostecki/openSUSE_Tumbleweed/home:mrostecki.repo
sudo zypper -n --gpg-auto-import-key in --no-recommends \
        python3-sphinxcontrib-openapi \
    && sudo zypper clean
