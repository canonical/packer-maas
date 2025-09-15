#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

SERIES ?= jammy
ARCH ?= amd64
URL ?= http://releases.ubuntu.com
SUMS ?= SHA256SUMS
TIMEOUT ?= 1h
OVMF ?= OVMF

# Detect if running on ARM host
ifeq ($(shell uname -m),aarch64)
	HOST_IS_ARM = true
	OVMF = AAVMF
else
	HOST_IS_ARM = false
endif

ifeq ($(wildcard /usr/share/$(OVMF)/$(OVMF)_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

ifeq ($(strip $(ARCH)),arm64)
	URL = https://cdimage.ubuntu.com/releases
	ISO=$(shell wget -O- -q ${URL}/${SERIES}/release/${SUMS} | grep live-server | grep ${ARCH}.iso| cut -d'*' -f2 | tail -n1)
else
	ISO=$(shell wget -O- -q ${URL}/${SERIES}/${SUMS} | grep live-server | cut -d'*' -f2 | tail -n1)
endif

.PHONY: all clean

all: custom-cloudimg.tar.gz

$(eval $(call check_packages_deps,cloud-image-utils ovmf parted,cloud-image-utils ovmf parted))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd:
ifeq ($(strip $(ARCH)),arm64)
	truncate -s 64m OVMF_VARS.fd
else
	truncate -s 2m OVMF_VARS.fd
endif

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

custom-cloudimg.tar.gz: check-deps clean OVMF_CODE.fd OVMF_VARS.fd SIZE_CODE.fd SIZE_VARS.fd
	${PACKER} init . && ${PACKER} build \
		-only='cloudimg.*' $(if ${CUSTOMIZE},-var customize_script=${CUSTOMIZE}) \
		-var ubuntu_series=${SERIES} \
		-var architecture=${ARCH} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .

custom-ubuntu.tar.gz: check-deps clean seeds-flat.iso OVMF_CODE.fd OVMF_VARS.fd SIZE_CODE.fd SIZE_VARS.fd \
			packages/custom-packages.tar.gz
	${PACKER} init . && ${PACKER} build -only=qemu.flat \
		-var ubuntu_series=${SERIES} \
		-var ubuntu_iso=${ISO} \
		-var architecture=${ARCH} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .

custom-ubuntu-lvm.dd.gz: check-deps clean seeds-lvm.iso OVMF_CODE.fd OVMF_VARS.fd SIZE_CODE.fd SIZE_VARS.fd
	${PACKER} init . && ${PACKER} build -only=qemu.lvm \
		-var ubuntu_series=${SERIES} \
		-var ubuntu_iso=${ISO} \
		-var architecture=${ARCH} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .
clean:
	${RM} -rf output-* custom-*.gz \
		seeds-flat.iso seeds-lvm.iso seeds-cloudimg.iso \
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
	seeds-flat.iso seeds-lvm.iso seeds-cloudimg.iso
