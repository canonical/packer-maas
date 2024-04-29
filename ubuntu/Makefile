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

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

ISO=$(shell wget -O- -q ${URL}/${SERIES}/${SUMS} | grep live-server | cut -d'*' -f2)

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

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.fd
	cp -v $< $@

custom-cloudimg.tar.gz: check-deps clean
	${PACKER} init . && ${PACKER} build \
		-only='cloudimg.*' \
		-var ubuntu_series=${SERIES} \
		-var architecture=${ARCH} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .

custom-ubuntu.tar.gz: check-deps clean seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	${PACKER} init . && ${PACKER} build -only=qemu.flat \
		-var ubuntu_series=${SERIES} \
		-var ubuntu_iso=${ISO} \
		-var architecture=${ARCH} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .

custom-ubuntu-lvm.dd.gz: check-deps clean seeds-lvm.iso OVMF_VARS.fd
	${PACKER} init . && ${PACKER} build -only=qemu.lvm \
		-var ubuntu_series=${SERIES} \
		-var ubuntu_lvm_iso=${ISO} \
		-var architecture=${ARCH} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var timeout=${TIMEOUT} .
clean:
	${RM} -rf output-* custom-*.gz \
		seeds-flat.iso seeds-lvm.iso seeds-cloudimg.iso \
		OVMF_VARS.fd

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: OVMF_VARS.fd packages/custom-packages.tar.gz \
	seeds-flat.iso seeds-lvm.iso seeds-cloudimg.iso
