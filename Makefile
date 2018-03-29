DISTRIBUTION ?= ubuntu
JQ ?= del(."post-processors"[])

ifeq ($(DISTRIBUTION), ubuntu)
JSON_FILE = cilium-ubuntu.json
BOX_FILE = cilium-ginkgo-virtualbox-iso.box
else ifeq ($(DISTRIBUTION), opensuse)
JSON_FILE = cilium-opensuse.json
BOX_FILE = cilium-ginkgo-opensuse-virtualbox-iso.box
else
$(error "Distribution $(DISTRIBUTION) is unsupported")
endif

all: build

fetch-opensuse-ovf:
ifeq ($(DISTRIBUTION), opensuse)
	./tools/download-opensuse-ovf.sh
endif

build: fetch-opensuse-ovf validate
	jq '$(JQ)' $(JSON_FILE) | packer build -

validate:
	jq '$(JQ)' $(JSON_FILE) | packer validate -

clean:
	rm -Rf $(BOX_FILE) virtualbox.box tmp packer_cache packer-* opensuse_base_box

install:
	vagrant box add --force cilium/$(DISTRIBUTION) $(BOX_FILE)

.PHONY = fetch-opensuse-ovf build validate clean install
