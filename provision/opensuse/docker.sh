#!/bin/bash

set -e

sudo systemctl enable docker
sudo systemctl restart docker

sudo usermod -aG docker vagrant
