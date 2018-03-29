#!/usr/bin/env bash

# This script makes symlinks for several libraries from /usr/lib64 to
# /usr/lib, which is a workaround for Envoy build system which doesn't look for
# libraries in /usr/lib64.
# TODO(mrostecki): Fix Envoy's Bazel config properly, in upstream.

set -eux

LIBS=(libcares.a libevent.a libevent_pthreads.a libnghttp2.a libtcmalloc_and_profiler.a)

for lib in $LIBS; do
    ln -s /usr/lib64/$lib /usr/lib/$lib
done
