#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

for img in consul:1.1.0; do
  sudo docker pull $img &
done

# Install all of these images in VM for the CI
if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        borkmann/misc \
        busybox:latest \
        byrnedo/alpine-curl \
        cilium/connectivity-container:v1.0 \
        cilium/demo-client \
        cilium/demo-httpd \
        cilium/kafkaclient \
        cilium/kafkaclient2 \
        cilium/microscope:1.1.0-ci \
        cilium/starwars \
        coredns/coredns:1.0.6 \
        digitalwonderland/zookeeper \
        docker.io/wurstmeister/kafka:1.1.0 \
        gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.10 \
        gcr.io/google_samples/gb-redisslave:v1 \
        httpd \
        istio/examples-bookinfo-details-v1:1.6.0 \
        istio/examples-bookinfo-productpage-v1:0.2.3 \
        istio/examples-bookinfo-ratings-v1:1.6.0 \
        istio/examples-bookinfo-reviews-v1:1.6.0 \
        istio/examples-bookinfo-reviews-v2:1.6.0 \
        kubernetes/guestbook:v2 \
        quay.io/cilium/cilium-builder:2018-08-17 \
        quay.io/cilium/cilium-runtime:2018-08-06 \
        quay.io/coreos/etcd:v3.2.17 \
        redis \
        registry \
        tgraf/netperf; \
        do
          echo "pulling image: $img"
          sudo docker pull "${img}" &
    done
fi

for p in `jobs -p`; do
  wait $p
done
