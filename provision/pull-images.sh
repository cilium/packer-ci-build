#!/usr/bin/env bash

source "${ENV_FILEPATH}"

set -e

trap "docker images" EXIT

for img in consul:1.1.0; do
  sudo docker pull $img &
done

if [ -z "${NAME_PREFIX}" ]; then
    for img in \
        docker.io/cilium/demo-client:1.0 \
        docker.io/cilium/demo-httpd:1.0 \
        docker.io/cilium/dnssec-client:v0.2 \
        docker.io/cilium/docker-bind:v0.3 \
        docker.io/cilium/echoserver:1.10.1 \
        docker.io/cilium/echoserver-udp:v2020.01.30 \
        docker.io/cilium/json-mock:1.2 \
        docker.io/cilium/kafkaclient:1.0 \
        docker.io/cilium/kafkaproxy:1.0 \
        docker.io/cilium/log-gatherer:v1.1 \
        docker.io/cilium/migrate-svc-test:v0.0.2 \
        docker.io/cilium/netperf:2.0 \
        docker.io/cilium/zookeeper:1.0 \
        docker.io/frrouting/frr:v7.5.1 \
        docker.io/istio/examples-bookinfo-details-v1:1.16.2 \
        docker.io/istio/examples-bookinfo-productpage-v1:0.2.3 \
        docker.io/istio/examples-bookinfo-ratings-v1:1.16.2 \
        docker.io/istio/examples-bookinfo-reviews-v1:1.6.0 \
        docker.io/istio/examples-bookinfo-reviews-v2:1.6.0 \
        docker.io/library/busybox:1.31.1 \
        docker.io/library/golang:${GOLANG_VERSION} \
        docker.io/library/redis:6.0.5 \
        docker.io/networkstatic/iperf3@sha256:e9bbc8312edff13e2ecccad0907db4b35119139e133719138108955cf07f0683 \
        docker.io/wurstmeister/kafka:2.11-0.11.0.3 \
        gcr.io/google-samples/gb-frontend:v6 \
        gcr.io/google_samples/gb-redis-follower:v2 \
        k8s.gcr.io/coredns/coredns:v1.8.3 \
        quay.io/cilium/alpine-curl:v1.3.0 \
        quay.io/cilium/cilium-bpftool:78448c1a37ff2b790d5e25c3d8b8ec3e96e6405f \
        quay.io/cilium/cilium-builder:6284fc1a4c7206b8bee0d9309e0b6e331f564618 \
        quay.io/cilium/cilium-envoy:e90612180b82d07c124bbf8e1ffe94a8d603f8ae \
        quay.io/cilium/cilium-iproute2:02c29c971c01f0b9a7b916327f0caedd83820c18 \
        quay.io/cilium/cilium-llvm:547db7ec9a750b8f888a506709adb41f135b952e \
        quay.io/cilium/cilium-runtime:05ac87c6a2ef4f24e6ba9acf8b06e8c2362cab2f \
        quay.io/cilium/image-compilers:e847f4176cb42ae27fa459a10df6721c43702b64 \
        quay.io/cilium/image-tester:c37f768323abfba87c90cd9c82d37136183457bc \
        quay.io/cilium/cilium-envoy:9c0d933166ba192713f9e2fc3901f788557286ee \
        quay.io/cilium/istio_pilot:1.10.4 \
        quay.io/cilium/istio_proxy:1.10.4 \
        quay.io/cilium/test-verifier:110522f9cb32ac55b68db668433c85268945be5f \
        quay.io/cilium/kube-wireguarder:0.0.4 \
        quay.io/cilium/net-test:v1.0.0 \
        quay.io/coreos/etcd:v3.4.7 \

    do
          echo "pulling image: $img"
          if [ -z "$NETNEXT" ]; then
             sudo docker pull "${img}" --quiet &
          else
             sudo sudo ctr images pull "${img}" >/dev/null &
          fi
    done
fi

for p in `jobs -p`; do
  wait $p
done

echo "Done pulling images"
