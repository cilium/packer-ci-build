#!/bin/bash

sudo mkdir /go/ &&\
export GOPATH=/go/ &&\
go get -u github.com/jteeuwen/go-bindata/... && \
go get -u github.com/google/gops && \
go get -u github.com/golang/protobuf/protoc-gen-go && \
sudo ln -sf /go/bin/* /usr/local/bin/
