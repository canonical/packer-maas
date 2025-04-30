#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

BOOT ?= uefi
OVMF ?= OVMF

ifeq ($(wildcard /usr/share/$(OVMF)/$(OVMF)_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

.PHONY: all clean

all: pve

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

pve: check-deps clean OVMF_CODE.fd OVMF_VARS.fd
	${PACKER} init . && ${PACKER} build .

clean:
	${RM} -rf output-* \
		OVMF_VARS.fd \
		OVMF_CODE.fd
