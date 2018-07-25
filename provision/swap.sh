#!/usr/bin/env bash

# Disable swap filesystem by default. Needed by kubernetes >1.7
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo sh -c 'echo "sysctl vm.swappiness=0" > /etc/sysctl.d/60-swappiness.conf'
