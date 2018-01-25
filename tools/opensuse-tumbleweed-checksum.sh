#!/bin/bash

# openSUSE Tumbleweed is a rolling release distribution which delivers ISO
# images daily. It means that the SHA256 checksum of the ISO changes every day.
# This script returns the current checksum of the newest available ISO.

CHECKSUM_URL=http://widehat.opensuse.org/tumbleweed/iso/openSUSE-Tumbleweed-NET-x86_64-Current.iso.sha256

echo $(curl "$CHECKSUM_URL" | awk '/iso/{print $1;}')
