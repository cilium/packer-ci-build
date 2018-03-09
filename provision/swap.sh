#!/usr/bin/env bash

#Disable swap filesystem by default. Needed by kubernetes >1.7
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
