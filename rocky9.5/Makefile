#!/usr/bin/make -f

PACKER ?= packer
PACKER_LOG ?= 1
TIMEOUT ?= 1h
ARCH ?= x86_64

ifeq ($(shell uname -m),aarch64)
	HOST_IS_ARM = true
else
	HOST_IS_ARM = false
endif

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

export PACKER_LOG

.PHONY: all clean validate doca gpu

all: cpu gpu

validate:
	${PACKER} fmt -check -diff .
	${PACKER} validate rocky9.pkr.hcl

clean:
	${RM} -rf *.fd output-rocky9 *.qcow2

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS${OVMF_SFX}.fd
	cp -v $< ${ARCH}_VARS.fd

SIZE_VARS.fd:
	truncate -s 2m ${ARCH}_VARS.fd

cpu: clean OVMF_VARS.fd SIZE_VARS.fd
	${PACKER} init rocky9.pkr.hcl && \
	${PACKER} build \
		-var architecture=${ARCH} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var timeout=${TIMEOUT} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var image_type="doca" \
		rocky9.pkr.hcl

gpu: clean OVMF_VARS.fd SIZE_VARS.fd
	${PACKER} init rocky9.pkr.hcl && \
	${PACKER} build \
		-var architecture=${ARCH} \
		-var host_is_arm=${HOST_IS_ARM} \
		-var timeout=${TIMEOUT} \
		-var ovmf_suffix=${OVMF_SFX} \
		-var image_type="gpu" \
		rocky9.pkr.hcl

