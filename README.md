foo

# cilium/packer-ci-build

This repo contains [packer](https://packer.io) templates and Jenkinsfiles to
build the Vagrant boxes used for running Cilium's integration tests.

The built Vagrant boxes contain a variety of Cilium build and test dependencies,
like Go, Kubernetes, Docker, a Docker registry, etcd, and more.

## Building Cilium Vagrant boxes locally

1. Ensure you have [packer](https://www.packer.io/) installed.

2. Make your changes locally and run

   ```console
   $ for d in ubuntu ubuntu-next ubuntu-4-19 ubuntu-5-4 ; do make DISTRIBUTION=$d ; done
   ```

   to build each of the four images.

## Updating the Cilium Vagrant boxes used in tests

The Vagrant boxes are built by Cilium's CI infrastructure. The process is
described in [the Packer-CI-Build section of Cilium's
documentation](https://github.com/cilium/cilium/blob/master/Documentation/contributing/testing/ci.rst#packer-ci-build)

## History

This was ported from
[github.com/eloycoto/cilium_basebox](https://github.com/eloycoto/cilium_basebox),
which was created by [@eloycoto](https://github.com/eloycoto) as part of his
work contributing to Cilium.
