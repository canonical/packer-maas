# Makefile
TALOS_VERSION ?= v1.14.2
ARCH          ?= amd64
PLATFORM      ?= metal
# Space-separated, e.g. EXTENSIONS="siderolabs/iscsi-tools siderolabs/util-linux-tools"
EXTENSIONS    ?=

MAAS_PROFILE  ?= admin
MAAS_NAME     ?= custom/talos
PACKER        ?= packer

OUTPUT := talos-$(TALOS_VERSION)-$(ARCH).raw.gz

# Convert the space-separated EXTENSIONS into an HCL list: ["a","b"]
comma := ,
empty :=
space := $(empty) $(empty)
EXT_HCL := [$(subst $(space),$(comma),$(foreach e,$(EXTENSIONS),"$(e)"))]

.PHONY: all build upload clean distclean

all: $(OUTPUT)

build: $(OUTPUT)

$(OUTPUT): talos.pkr.hcl
	$(PACKER) init .
	$(PACKER) build \
		-var 'talos_version=$(TALOS_VERSION)' \
		-var 'arch=$(ARCH)' \
		-var 'platform=$(PLATFORM)' \
		-var 'extensions=$(EXT_HCL)' \
		talos.pkr.hcl

upload: $(OUTPUT)
	maas $(MAAS_PROFILE) boot-resources create \
		name='$(MAAS_NAME)' \
		title='Talos $(TALOS_VERSION) ($(ARCH))' \
		architecture='$(ARCH)/generic' \
		filetype='ddgz' \
		content@=$(OUTPUT)

clean:
	rm -f talos-*.raw.gz
