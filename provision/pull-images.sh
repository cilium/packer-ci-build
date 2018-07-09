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
      docker.io/wurstmeister/kafka:1.1.0 \
      digitalwonderland/zookeeper \
      cilium/kafkaclient2 cilium/kafkaclient cilium/starwars \
      redis gcr.io/google_samples/gb-redisslave:v1 \
      kubernetes/guestbook:v2 \
      cilium/connectivity-container \
      istio/examples-bookinfo-productpage-v1:0.2.3 \
      istio/examples-bookinfo-ratings-v1:1.6.0 istio/examples-bookinfo-reviews-v2:1.6.0 \
      istio/examples-bookinfo-details-v1:1.6.0 istio/examples-bookinfo-reviews-v1:1.6.0 \
      quay.io/cilium/cilium-runtime:2018-06-21 \
      quay.io/cilium/cilium-builder:2018-06-29; do
      sudo docker pull $img &
    done
fi

for p in `jobs -p`; do
  wait $p
done
