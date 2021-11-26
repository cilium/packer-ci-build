#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

trap "docker images" EXIT

for img in consul:1.1.0; do
  sudo docker pull $img &
done

if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        busybox:1.31.1 \
        docker.io/cilium/demo-client:1.0 \
        docker.io/cilium/demo-httpd:1.0 \
        docker.io/cilium/dnssec-client:v0.2 \
        docker.io/cilium/docker-bind:v0.3 \
        docker.io/cilium/dummylb:0.0.1 \
        docker.io/cilium/echoserver:1.10.1 \
        docker.io/cilium/echoserver-udp:v2020.01.30 \
        docker.io/cilium/json-mock:1.2 \
        docker.io/cilium/kafkaclient2:1.0 \
        docker.io/cilium/kafkaclient:1.0 \
        docker.io/cilium/kafkaproxy:1.0 \
        docker.io/cilium/log-gatherer:v1.1 \
        docker.io/cilium/migrate-svc-test:v0.0.2 \
        docker.io/cilium/netperf:2.0 \
        docker.io/cilium/python-bmemcached:v0.0.2 \
        docker.io/cilium/starwars:v1.0 \
        docker.io/cilium/zookeeper:1.0 \
        docker.io/frrouting/frr:v7.5.1 \
        docker.io/istio/examples-bookinfo-details-v1:1.16.2 \
        docker.io/istio/examples-bookinfo-productpage-v1:0.2.3 \
        docker.io/istio/examples-bookinfo-ratings-v1:1.16.2 \
        docker.io/istio/examples-bookinfo-reviews-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v2:1.6.0 \
        docker.io/library/alpine:3.12.7 \
        docker.io/library/cassandra:3.11.3 \
        docker.io/library/golang:1.17.3 \
        docker.io/library/memcached:1.6.6-alpine \
        docker.io/library/redis:6.0.5 \
        docker.io/tgraf/netperf:v1.0 \
        docker.io/wurstmeister/kafka:2.11-0.11.0.3 \
        gcr.io/google-samples/gb-frontend:v6 \
        gcr.io/google_samples/gb-redis-follower:v2 \
        k8s.gcr.io/coredns/coredns:v1.8.3 \
        quay.io/cilium/alpine-curl:v1.3.0 \
        quay.io/cilium/cilium-builder:796040ab4012e021232a8197b277e578da3df9f4 \
        quay.io/cilium/cilium-envoy:9b1701da9cc035a1696f3e492ee2526101262e56 \
        quay.io/cilium/istio_pilot:1.10.4 \
        quay.io/cilium/istio_proxy:1.10.4 \
        quay.io/cilium/test-verifier:0f6647c542b71e89f310e437570b6d05dd9351bb \
        quay.io/cilium/kube-wireguarder:0.0.4 \
        quay.io/cilium/net-test:v1.0.0 \
        quay.io/coreos/etcd:v3.4.7 \

    do
          echo "pulling image: $img"
          sudo docker pull "${img}" --quiet &
    done
fi

for p in `jobs -p`; do
  wait $p
done
