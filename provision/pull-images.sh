#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

trap "docker images" EXIT

for img in consul:1.1.0; do
  sudo docker pull $img &
done

if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        busybox:1.30.1 \
        busybox:1.31.1 \
        docker.io/byrnedo/alpine-curl:0.1.7 \
        k8s.gcr.io/coredns:1.2.2 \
        k8s.gcr.io/coredns:1.2.6 \
        k8s.gcr.io/coredns:1.3.1 \
        k8s.gcr.io/coredns:1.6.2 \
        k8s.gcr.io/coredns:1.6.5 \
        docker.io/cilium/cc-grpc-demo:v2.0 \
        docker.io/cilium/cilium:v1.6 \
        docker.io/cilium/demo-client:latest \
        docker.io/cilium/demo-httpd:latest \
        docker.io/cilium/docker-bind:v0.1 \
        docker.io/cilium/echoserver:1.10 \
        docker.io/cilium/echoserver-udp:v2020.01.30 \
        docker.io/cilium/istio_pilot:1.5.4 \
        docker.io/cilium/istio_proxy:1.5.4 \
        docker.io/cilium/json-mock:1.1 \
        docker.io/cilium/kafkaclient2:latest \
        docker.io/cilium/kafkaclient:latest \
        docker.io/cilium/log-gatherer:v1.0 \
        docker.io/cilium/migrate-svc-test:v0.0.1 \
        docker.io/cilium/starwars:v1.0 \
        docker.io/cilium/python-bmemcached:v0.0.1 \
        docker.io/cilium/dnssec-client:v0.1 \
        docker.io/cilium/docker-bind:v0.1 \
        docker.io/cilium/docker-bind:v0.3 \
        docker.io/digitalwonderland/zookeeper:latest \
        docker.io/istio/examples-bookinfo-details-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-productpage-v1:0.2.3 \
        docker.io/istio/examples-bookinfo-ratings-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v2:1.6.0 \
        docker.io/library/alpine:3.9 \
        docker.io/library/busybox:1.28.0 \
        docker.io/library/cassandra:3.11.3 \
        docker.io/library/httpd:2.4.34 \
        docker.io/library/memcached:1.5.11 \
        docker.io/library/redis:4.0.11 \
        docker.io/library/registry:2.6.2 \
        docker.io/prom/prometheus:v2.12.0 \
        docker.io/prom/statsd-exporter:v0.6.0 \
        docker.io/spotify/kafkaproxy:latest \
        docker.io/tgraf/netperf:v1.0 \
        docker.io/wurstmeister/kafka:2.11-0.11.0.3 \
        docker.io/metallb/controller:v0.8.2 \
        docker.io/metallb/speaker:v0.8.2 \
        gcr.io/google-samples/gb-frontend:v4 \
        gcr.io/google_samples/gb-redisslave:v1 \
        quay.io/cilium/cilium-envoy:a3385205ad620550b35d3b0b651e40898386e6e3 \
        quay.io/cilium/cilium-builder:2020-05-20 \
        quay.io/cilium/cilium-runtime:2020-05-20 \
        quay.io/cilium/hubble:v0.5.1 \
        quay.io/coreos/etcd:v3.2.17 \
        quay.io/coreos/etcd:v3.4.7 \
        quay.io/coreos/etcd-operator:v0.9.4; \

    do
          echo "pulling image: $img"
          sudo docker pull "${img}" --quiet &
    done
fi

for p in `jobs -p`; do
  wait $p
done
