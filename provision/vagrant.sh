#!/usr/bin/env bash

set -eux

#From: https://github.com/chef/bento/blob/master/ubuntu/scripts/vagrant.sh

source "${ENV_FILEPATH}"

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub";
mkdir -p "${HOME_DIR}/.ssh";
if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate "${pubkey_url}" -O "${HOME_DIR}/.ssh/authorized_keys";
elif command -v curl >/dev/null 2>&1; then
    curl --insecure --location "${pubkey_url}" > "${HOME_DIR}/.ssh/authorized_keys";
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chmod -R go-rwsx "${HOME_DIR}/.ssh";

echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant
sudo chmod 440 /etc/sudoers.d/99_vagrant

sudo sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
