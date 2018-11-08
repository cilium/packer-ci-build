#!/bin/bash

set -eux

# Disable swap
swapoff -a
# Remove swap partition permanently
parted /dev/sda rm $(parted /dev/sda print | awk '/swap/{print $1;}')
