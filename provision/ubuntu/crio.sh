#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

sudo add-apt-repository ppa:projectatomic/ppa

sudo apt-get update
sudo apt-get install -y cri-o-1.12
