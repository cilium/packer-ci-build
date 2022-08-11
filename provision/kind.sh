#!/usr/bin/env bash

# source "${ENV_FILEPATH}"

set -e

#
# Install kubectl
#
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$VM_ARCH/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
#
# Install Kind
#
go install sigs.k8s.io/kind@latest
if ! grep -i -e "PATH.*go.*/bin" ~/.profile ; then
   echo "PATH=\"\$GOPATH/bin:\$PATH\"" >> ~/.profile
fi
