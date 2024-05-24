#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${ISO_PATH}
export PACKER_LOG

TIMEOUT ?= 1h

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

.PHONY: all clean

all: azurelinux.tar.gz

$(eval $(call check_packages_deps,cloud-image-utils ovmf parted,cloud-image-utils ovmf parted))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.fd
	cp -v $< $@

azurelinux.tar.gz: check-deps clean OVMF_VARS.fd
	${PACKER} init . && ${PACKER} build \
		-var ovmf_suffix=${OVMF_SFX} \
		-var iso_url=${ISO} \
		-var timeout=${TIMEOUT} .
clean:
	${RM} -rf output* azurelinux.tar.gz \
		OVMF_VARS.fd

.INTERMEDIATE: OVMF_VARS.fd
