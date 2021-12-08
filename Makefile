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

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VM_CPUS ?= 4
VM_MEMORY ?= 4G
VM_DISK ?= 40G
VM_NAME ?= runtime
VM_ARCH ?= $(subst x86_64,amd64,$(subst aarch64,arm64,$(shell uname -m)))
VM_USERNAME ?= ubuntu
HOST_IP ?= 192.168.64.1

# share parent if it is named "cilium", so that it can be correctly mounted
# as ~/go/src/github.com/cilium"
ifeq (cilium,$(notdir $(abspath $(ROOT_DIR)/..)))
	SHARE_SOURCE ?= $(shell cd $(ROOT_DIR)/../.. && pwd)
	SHARE_TARGET ?= /home/$(VM_USERNAME)/go/src/github.com
else
	SHARE_SOURCE ?= $(shell cd $(ROOT_DIR)/.. && pwd)
	SHARE_TARGET ?= /home/$(VM_USERNAME)/go/src/github.com/cilium
endif

multipass: nfs-export
	@cp user-data.yaml /tmp
	@if [ -f ~/.ssh/id_rsa.pub ] ; then printf "\nssh_authorized_keys:\n  - " >> /tmp/user-data.yaml && cat ~/.ssh/id_rsa.pub >> /tmp/user-data.yaml; fi
	multipass launch -vvvv --disk $(VM_DISK) --cloud-init /tmp/user-data.yaml --cpus $(VM_CPUS) --mem $(VM_MEMORY) --name $(VM_NAME)
	echo "Launched multipass VM \"$(VM_NAME)\", use \"multipass delete $(VM_NAME) --purge\" to delete it."
	@multipass mount -u `id -u`:1000 -g `id -g`:1000 provision $(VM_NAME):/tmp/provision
	multipass exec $(VM_NAME) -- bash -c "VM_ARCH=$(VM_ARCH) KERNEL=${KERNEL} KERNEL_DATE=${KERNEL_DATE} NETNEXT=${NETNEXT} /tmp/provision/provision-kernel.sh 2>&1" | tee /tmp/provision.log
	@if tail /tmp/provision.log | grep "sudo reboot"; then \
		echo "Sleeping 1 minute after kernel reboot..."; \
		sleep 60; \
		echo "Resuming provisioning..."; \
		multipass mount -u `id -u`:1000 -g `id -g`:1000 provision $(VM_NAME):/tmp/provision || true; \
	elif ! tail /tmp/provision.log | grep "KEEPING KERNEL"; then \
		echo "*** Kernel provisioning failed, see /tmp/provision.log ***"; \
		exit 1; \
	fi
	multipass exec $(VM_NAME) -- bash -c "VM_ARCH=$(VM_ARCH) USERNAME=$(VM_USERNAME) PULL_IMAGES=${PULL_IMAGES} /tmp/provision/provision.sh 2>&1" | tee -a /tmp/provision.log
	@tail /tmp/provision.log | grep "PROVISIONING SUCCESSFULLY COMPLETED"
	@multipass umount $(VM_NAME):/tmp/provision || true
	@rm -f /tmp/user-data.yaml
	#
	# Add NFS mount to $(SHARE_TARGET)
	#
	multipass exec $(VM_NAME) -- mkdir -p $(SHARE_TARGET)
	multipass exec $(VM_NAME) -- sudo bash -c "echo \"$(HOST_IP):$(SHARE_SOURCE)	$(SHARE_TARGET)	nfs	defaults	0	0\" >>/etc/fstab && mount -a"
	#
	# Verify that NFS mount works
	#
	multipass exec $(VM_NAME) -- cat go/src/github.com/cilium/cilium/VERSION
	@rm -f /tmp/provision.log

nfs-export: HOST_NETWORK ?= $(basename $(HOST_IP)).0
nfs-export: HOST_MASK ?= 255.255.255.0
nfs-export: ETC_EXPORTS ?= $(realpath $(SHARE_SOURCE)) -mapall=$(shell whoami) -alldirs -network $(HOST_NETWORK) -mask $(HOST_MASK)
nfs-export:
	@if ! grep "$(ETC_EXPORTS)" /etc/exports; then \
		echo "Adding entry to /etc/exports, sudo password may be needed."; \
		sudo sh -c "echo >> /etc/exports \"$(ETC_EXPORTS)\""; \
		if [ -f `which nfsd` ]; then \
			sudo nfsd restart; \
		fi \
	else \
		echo /etc/exports already has line with "$(ETC_EXPORTS)"; \
	fi

.PHONY = build validate clean install multipass nfs-export
