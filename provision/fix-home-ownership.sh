#!/bin/sh

source "${ENV_FILEPATH}"

set -e

# Provisioning scripts run as root, causing files in the vagrant user's home
# directory to be owned by root, not vagrant. As a last step, fix the ownership
# of all files.
chown -R vagrant:vagrant "${HOME_DIR}"
