#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= XenServer8_2024-12-09.iso
TIMEOUT ?= 1h
ARCH ?= x86_64
HEADLESS ?= false

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

export PACKER_LOG

.PHONY: all clean

all: xenserver8-lvm.dd.gz

$(eval $(call check_packages_deps))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS${OVMF_SFX}.fd
	cp -v $< ${ARCH}_VARS.fd

SIZE_VARS.fd:
	truncate -s 2m ${ARCH}_VARS.fd

xenserver8-lvm.dd.gz: check-deps clean OVMF_VARS.fd SIZE_VARS.fd
	${PACKER} init xenserver8.pkr.hcl && ${PACKER} build \
							-var architecture=${ARCH} \
							-var headless=${HEADLESS} \
							-var ovmf_suffix=${OVMF_SFX} \
							-var "xenserver8_iso_path=${ISO}" \
							-var timeout=${TIMEOUT} \
							xenserver8.pkr.hcl

clean:
	${RM} -rf *.fd output-xenserver8 xenserver8-lvm.dd.gz
