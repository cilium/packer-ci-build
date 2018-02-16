#!/usr/bin/env bash

source "${ENV_FILEPATH}"

wget -nv "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"
chmod +x "bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"
sudo -E "./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"
sudo -E mv /usr/local/bin/bazel /usr/bin
rm "bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"

sudo -E mkdir -p "${GOPATH}/src/github.com/cilium"
sudo -E chmod 755 "${GOPATH}/src/github.com/cilium"
sudo -E chown vagrant:vagrant "${GOPATH}" -R

# TODO delete me once https://github.com/cilium/cilium/pull/2826 is merged
cat > ${HOME}/diff.patch <<EOF
diff --git a/envoy/Makefile b/envoy/Makefile
index 2be0db3a5..c7c547eeb 100644
--- a/envoy/Makefile
+++ b/envoy/Makefile
@@ -78,7 +78,7 @@ BAZEL_BUILD_OPTS = --spawn_strategy=standalone --genrule_strategy=standalone
 all: clean-bins release
 else
 BAZEL_OPTS ?=
-BAZEL_BUILD_OPTS =
+BAZEL_BUILD_OPTS = --experimental_strict_action_env

 all: clean-bins envoy \$(GO_TARGETS)
 endif
EOF

sudo -u vagrant -E sh -c "\
    cd \"${GOPATH}/src/github.com/cilium\" && \
    git clone -b master https://github.com/cilium/cilium.git && \
    cd cilium && \
    git submodule update --init --recursive && \
    patch -p1 < ${HOME}/diff.patch && \
    cd envoy && \
    grep \"ENVOY_SHA[ \t]*=\" WORKSPACE | cut -d \\\" -f 2 >SOURCE_VERSION && \
    cat SOURCE_VERSION && \
    make && \
    make PKG_BUILD=1"

sudo rm -fr "${GOPATH}/src/github.com/cilium"
