#!/bin/bash

sudo mkdir /home/vagrant/go &&\
export GOPATH=/home/vagrant/go &&\
go get -u github.com/jteeuwen/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go

# symlink all go bins to /usr/bin so envoy can use them without
# changing envoy's PATH to include $GOPATH/bin
sudo ln -s /home/vagrant/go/bin/* /usr/local/bin
