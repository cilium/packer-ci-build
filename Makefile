DISTRIBUTION ?= ubuntu
JQ ?= del(."post-processors"[])
PACKER ?= packer

ifeq ($(DISTRIBUTION), ubuntu)
JSON_FILE = cilium-ubuntu.json
BOX_FILE = cilium-ginkgo-virtualbox-iso.box
else ifeq ($(DISTRIBUTION), opensuse)
JSON_FILE = cilium-opensuse.json
BOX_FILE = cilium-ginkgo-opensuse-virtualbox-iso.box
else ifeq ($(DISTRIBUTION), ubuntu-next)
JSON_FILE = cilium-ubuntu-next.json
BOX_FILE = cilium-ginkgo-virtualbox-iso-next.box
else ifeq ($(DISTRIBUTION), ubuntu-4.19)
JSON_FILE = cilium-ubuntu-4.19.json
BOX_FILE = cilium-ginkgo-virtualbox-iso-4.19.box
else
$(error "Distribution $(DISTRIBUTION) is unsupported")
endif

all: build

build: clean fetch-opensuse-ovf validate
	jq '$(JQ)' $(JSON_FILE) | $(PACKER) build $(ARGS) -

validate:
	jq '$(JQ)' $(JSON_FILE) | $(PACKER) validate -

clean:
	rm -Rf $(BOX_FILE) tmp packer_cache packer-*

fetch-opensuse-ovf:
ifeq ($(DISTRIBUTION), opensuse)
	./tools/download-opensuse-ovf.sh
endif

install:
	vagrant box add --force cilium/$(DISTRIBUTION) $(BOX_FILE)

.PHONY = build validate clean fetch-opensuse-ovf install
