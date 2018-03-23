#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

for img in tgraf/netperf httpd cilium/demo-httpd \
  cilium/demo-client borkmann/misc \
  registry busybox:latest quay.io/coreos/etcd:v3.1.0 \
  digitalwonderland/zookeeper wurstmeister/kafka \
  cilium/kafkaclient2 cilium/starwars; do
  sudo docker pull $img &
done

for p in `jobs -p`; do
  wait $p
done
