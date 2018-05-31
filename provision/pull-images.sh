#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

for img in consul:0.8.3; do
  sudo docker pull $img &
done

# Install all of these images in VM for the CI
if [ -z "${NAME_PREFIX}" ]; then
    for img in tgraf/netperf httpd cilium/demo-httpd \
      cilium/demo-client borkmann/misc \
      registry busybox:latest quay.io/coreos/etcd:v3.1.0 \
      digitalwonderland/zookeeper wurstmeister/kafka \
      cilium/kafkaclient2 cilium/starwars \
      istio/examples-bookinfo-ratings-v1:1.6.0 istio/examples-bookinfo-reviews-v2:1.6.0 \
      istio/examples-bookinfo-details-v1:1.6.0 istio/examples-bookinfo-reviews-v1:1.6.0; do
      sudo docker pull $img &
    done
fi

for p in `jobs -p`; do
  wait $p
done
