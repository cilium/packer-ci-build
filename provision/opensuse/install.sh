#!/usr/bin/env bash

set -eux

sudo zypper -n ar -r https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Factory/devel:languages:go.repo
sudo zypper -n ar -r https://download.opensuse.org/repositories/home:/mrostecki/openSUSE_Tumbleweed/home:mrostecki.repo
sudo zypper -n --gpg-auto-import-key in --no-recommends \
        go1.9 \
        python3-sphinxcontrib-openapi \
    && sudo zypper clean
