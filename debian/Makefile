#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

SERIES ?= bullseye
BOOT ?= uefi
ARCH ?= amd64
TIMEOUT ?= 1h
OVMF ?= OVMF

ifeq ($(strip $(SERIES)),buster)
	VERSION = 10
else ifeq ($(strip $(SERIES)),bullseye)
	VERSION = 11
else ifeq ($(strip $(SERIES)),bookworm)
	VERSION = 12
else ifeq ($(strip $(SERIES)),trixie)
	VERSION = 13
else
	VERSION = 12
endif

# Detect if running on ARM host
ifeq ($(shell uname -m),aarch64)
	HOST_IS_ARM = true
	OVMF = AAVMF
else
	HOST_IS_ARM = false
endif

# Safeguard
ifeq ($(strip $(ARCH)),arm64)
	boot = uefi
endif

ifeq ($(wildcard /usr/share/$(OVMF)/$(OVMF)_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

.PHONY: all clean

all: debian

$(eval $(call check_packages_deps,cloud-image-utils ovmf,cloud-image-utils ovmf))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

OVMF_VARS.fd: /usr/share/${OVMF}/${OVMF}_VARS${OVMF_SFX}.fd
	cp -v $< OVMF_VARS.fd

OVMF_CODE.fd: /usr/share/${OVMF}/${OVMF}_CODE${OVMF_SFX}.fd
	cp -v $< OVMF_CODE.fd


SIZE_VARS.fd:
ifeq ($(strip $(ARCH)),arm64)
	truncate -s 64m OVMF_VARS.fd
endif


SIZE_CODE.fd:
ifeq ($(strip $(ARCH)),arm64)
	truncate -s 64m OVMF_CODE.fd
endif

debian: check-deps clean OVMF_CODE.fd OVMF_VARS.fd SIZE_CODE.fd SIZE_VARS.fd
	${PACKER} init . && ${PACKER} build \
		-var debian_series=${SERIES} \
		-var debian_version=${VERSION} \
		-var architecture=${ARCH} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var boot_mode=${BOOT} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var timeout=${TIMEOUT} .

clean:
	${RM} -rf output-* debian-custom-*.gz \
		seeds-cloudimg.iso \
		OVMF_VARS.fd \
		OVMF_CODE.fd

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: packages/custom-packages.tar.gz \
	seeds-cloudimg.iso
