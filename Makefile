ARGS =
DISTRIBUTION ?= ubuntu
JQ ?= del(."post-processors"[])

ifeq ($(DISTRIBUTION), ubuntu)
JSON_FILE = cilium-ubuntu.json
BOX_FILE = cilium-ginkgo-virtualbox-iso.box
else ifeq ($(DISTRIBUTION), opensuse)
# openSUSE Tumbleweed is a rolling release distribution which delivers ISO
# images daily. It means that the SHA256 checksum of the ISO changes every day
# and we need to fetch it during box building.
JSON_FILE = cilium-opensuse.json
BOX_FILE = cilium-ginkgo-opensuse-virtualbox-iso.box
ISO_URL = http://widehat.opensuse.org/tumbleweed/iso/openSUSE-Tumbleweed-NET-x86_64-Current.iso
ISO_CHECKSUM = $(shell $(CURDIR)/tools/opensuse-tumbleweed-checksum.sh)
ARGS += -var iso_url=$(ISO_URL) -var iso_checksum=$(ISO_CHECKSUM)
else
$(error "Distribution $(DISTRIBUTION) is unsupported")
endif

all: build

build: clean validate
	jq '$(JQ)' $(JSON_FILE) | packer build $(ARGS) -

validate:
	jq '$(JQ)' $(JSON_FILE) | packer validate -

clean:
	rm -Rf $(BOX_FILE) tmp packer_cache packer-*

install:
	vagrant box add --force cilium/$(DISTRIBUTION) $(BOX_FILE)

.PHONY = build validate clean install
