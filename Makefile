DISTRIBUTION ?= ubuntu
JQ ?= del(."post-processors"[])
PACKER ?= packer

ifeq ($(DISTRIBUTION), ubuntu)
JSON_FILE = cilium-ubuntu.json
BOX_FILE = cilium-ginkgo-virtualbox-iso.box
else ifeq ($(DISTRIBUTION), ubuntu-next)
JSON_FILE = cilium-ubuntu-next.json
BOX_FILE = cilium-ginkgo-virtualbox-iso-next.box
else ifeq ($(DISTRIBUTION), ubuntu-4-19)
JSON_FILE = cilium-ubuntu-4.19.json
BOX_FILE = cilium-ginkgo-virtualbox-iso-4-19.box
else ifeq ($(DISTRIBUTION), ubuntu-5-4)
JSON_FILE = cilium-ubuntu-5.4.json
BOX_FILE = cilium-ginkgo-virtualbox-iso-5-4.box
else
$(error "Distribution $(DISTRIBUTION) is unsupported")
endif

all: build

build: clean validate
	jq '$(JQ)' $(JSON_FILE) | $(PACKER) build $(ARGS) -

validate:
	jq '$(JQ)' $(JSON_FILE) | $(PACKER) validate -

clean:
	rm -Rf $(BOX_FILE) tmp packer_cache packer-*

install:
	vagrant box add --force cilium/$(DISTRIBUTION) $(BOX_FILE)

# Sane defaults for a VM used for development
VM_CPUS ?= 8
VM_MEMORY ?= 24G
VM_DISK ?= 120G
VM_NAME ?= dev

multipass:
	VM_CPUS=$(VM_CPUS) VM_MEMORY=$(VM_MEMORY) VM_DISK=$(VM_DISK) provision/multipass.sh ${VM_NAME}

multipass-continue:
	VM_CPUS=$(VM_CPUS) VM_MEMORY=$(VM_MEMORY) VM_DISK=$(VM_DISK) provision/multipass.sh -c ${VM_NAME}

# VM_NAME must exists as an env variable
multipass-reinstall:
	VM_CPUS=$(VM_CPUS) VM_MEMORY=$(VM_MEMORY) VM_DISK=$(VM_DISK) provision/multipass.sh -f ${VM_NAME}

multipass-netnext:
	NETNEXT=true VM_CPUS=$(VM_CPUS) VM_MEMORY=$(VM_MEMORY) VM_DISK=$(VM_DISK) provision/multipass.sh netnext

multipass-netnext-reinstall:
	NETNEXT=true VM_CPUS=$(VM_CPUS) VM_MEMORY=$(VM_MEMORY) VM_DISK=$(VM_DISK) provision/multipass.sh -f netnext

.PHONY = build validate clean install multipass multipass-reinstall multipass-netnext multipass-netnext-reinstall
