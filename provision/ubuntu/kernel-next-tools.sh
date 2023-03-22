#!/bin/bash

set -ex

# Install perf tool

cd $HOME/k/tools/perf
make
sudo make install
