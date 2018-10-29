#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

for img in consul:1.1.0; do
  sudo docker pull $img &
done

# Install all of these images in VM for the CI
if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        docker.io/byrnedo/alpine-curl:0.1.7 \
        docker.io/cilium/cc-grpc-demo:v2.0 \
        docker.io/cilium/cilium:v1.0.7 \
        docker.io/cilium/cilium:v1.1.6 \
        docker.io/cilium/cilium:v1.2.5 \
        docker.io/cilium/cilium-init:2018-10-16 \
        docker.io/cilium/connectivity-container:v1.0 \
        docker.io/cilium/demo-client:latest \
        docker.io/cilium/demo-httpd:latest \
        docker.io/cilium/kafkaclient2:latest \
        docker.io/cilium/kafkaclient:latest \
        docker.io/cilium/microscope:1.1.2-ci \
        docker.io/cilium/starwars:v1.0 \
        docker.io/coredns/coredns:1.2.2 \
        docker.io/coredns/coredns:1.0.6 \
        docker.io/digitalwonderland/zookeeper:latest \
        docker.io/istio/examples-bookinfo-details-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-productpage-v1:0.2.3 \
        docker.io/istio/examples-bookinfo-ratings-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v2:1.6.0 \
        docker.io/kubernetes/guestbook:v2 \
        docker.io/library/busybox:1.28.0 \
        docker.io/library/httpd:2.4.34 \
        docker.io/library/redis:4.0.11 \
        docker.io/library/registry:2.6.2 \
        docker.io/tgraf/netperf:v1.0 \
        docker.io/wurstmeister/kafka:1.1.0 \
        docker.io/nebril/python-binary-memcached \
        docker.io/memcached:1.5.11 \
        gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.10 \
        gcr.io/google_samples/gb-redisslave:v1 \
        quay.io/cilium/cilium-builder:2018-10-29 \
        quay.io/cilium/cilium-runtime:2018-10-29 \
        quay.io/coreos/etcd:v3.2.17 \
        quay.io/coreos/etcd:v3.3.9; \
        do
          echo "pulling image: $img"
          sudo docker pull "${img}" &
    done
fi

for p in `jobs -p`; do
  wait $p
done
