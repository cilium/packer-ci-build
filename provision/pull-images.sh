#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

for img in consul:1.1.0; do
  sudo docker pull $img &
done

# Install all of these images in VM for the CI
if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        busybox:1.28.4 \
        busybox:1.30.1 \
        docker.io/byrnedo/alpine-curl:0.1.7 \
        docker.io/cilium/cc-grpc-demo:v2.0 \
        docker.io/cilium/cilium:v1.3.0 \
        docker.io/cilium/cilium-init:2018-10-16 \
        docker.io/cilium/connectivity-container:v1.0 \
        docker.io/cilium/demo-client:latest \
        docker.io/cilium/demo-httpd:latest \
        docker.io/cilium/docker-bind:v0.1 \
        docker.io/cilium/istio_pilot:1.2.4 \
        docker.io/cilium/istio_proxy:1.2.4 \
        docker.io/cilium/kafkaclient2:latest \
        docker.io/cilium/kafkaclient:latest \
        docker.io/cilium/microscope:1.1.2-ci \
        docker.io/cilium/starwars:v1.0 \
        docker.io/coredns/coredns:1.2.2 \
        docker.io/coredns/coredns:1.0.6 \
        docker.io/digitalwonderland/zookeeper:latest \
        docker.io/istio/citadel:1.2.4 \
        docker.io/istio/galley:1.2.4 \
        docker.io/istio/kubectl:1.2.4 \
        docker.io/istio/mixer:1.2.4 \
        docker.io/istio/proxy_init:1.2.4 \
        docker.io/istio/examples-bookinfo-details-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-productpage-v1:0.2.3 \
        docker.io/istio/examples-bookinfo-ratings-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v2:1.6.0 \
        docker.io/library/busybox:1.28.0 \
        docker.io/library/httpd:2.4.34 \
        docker.io/library/redis:4.0.11 \
        docker.io/library/registry:2.6.2 \
        docker.io/prom/prometheus:v2.3.1 \
        docker.io/prom/statsd-exporter:v0.6.0 \
        docker.io/tgraf/netperf:v1.0 \
        docker.io/wurstmeister/kafka:1.1.0 \
        docker.io/cilium/python-bmemcached:v0.0.1 \
        docker.io/memcached:1.5.11 \
        docker.io/spotify/kafkaproxy:latest \
        docker.io/cilium/dnssec-client:v0.1 \
        docker.io/cilium/docker-bind:v0.3 \
        gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.10 \
        gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.10 \
        gcr.io/google-samples/gb-frontend:v4 \
        gcr.io/google_samples/gb-redisslave:v1 \
        k8s.gcr.io/coredns:1.2.6 \
        quay.io/cilium/cilium-builder:2019-06-06 \
        quay.io/cilium/cilium-runtime:2019-05-22 \
        quay.io/coreos/etcd:v3.3.11 \
        quay.io/coreos/hyperkube:v1.7.6_coreos.0 \
        quay.io/coreos/etcd-operator:v0.9.4 \
        docker.io/cilium/migrate-svc-test:v0.0.1; \
    do
          echo "pulling image: $img"
          sudo docker pull "${img}" &
    done
fi

for p in `jobs -p`; do
  wait $p
done
