#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h
ARCH ?= x86_64

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

export PACKER_LOG

# Fallback
ifeq ($(strip $(ARCH)),amd64)
	ARCH = x86_64
endif

.PHONY: all clean

all: rocky8.tar.gz

$(eval $(call check_packages_deps))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS${OVMF_SFX}.fd
	cp -v $< ${ARCH}_VARS.fd

SIZE_VARS.fd:
ifeq ($(strip $(ARCH)),aarch64)
	truncate -s 64m ${ARCH}_VARS.fd
else
	truncate -s 2m ${ARCH}_VARS.fd
endif

rocky8.tar.gz: check-deps clean OVMF_VARS.fd SIZE_VARS.fd
	${PACKER} init rocky8.pkr.hcl && ${PACKER} build \
		-var architecture=${ARCH} \
		-var timeout=${TIMEOUT} \
		-var ovmf_suffix=${OVMF_SFX} \
		rocky8.pkr.hcl

clean:
	${RM} -rf *.fd output-rocky8 rocky8.tar.gz
