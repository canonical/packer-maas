#!/usr/bin/make -f

include ../scripts/check.mk

all: cpu gpu

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h
ARCH ?= x86_64

# Detect if running on ARM host
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

export PACKER_LOG=1

# Fallback
ifeq ($(strip $(ARCH)),amd64)
	ARCH = x86_64
endif

.PHONY: all cpu gpu clean list help validate

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

#rocky9.tar.gz: check-deps clean OVMF_VARS.fd SIZE_VARS.fd
#	${PACKER} init rocky9.pkr.hcl && ${PACKER} build \
#		-var architecture=${ARCH} \
#		-var host_is_arm=${HOST_IS_ARM} \
#		-var timeout=${TIMEOUT} \
#		-var ovmf_suffix=${OVMF_SFX} \
#		rocky9.pkr.hcl
validate:
	@echo "Validating Packer template..."
	${PACKER} init rocky9.pkr.hcl
	${PACKER} validate rocky9.pkr.hcl

list:
	@echo "Available image targets:"
	@echo "  make cpu   - Build Rocky + MOFED (rocky-cpu.qcow2)"
	@echo "  make gpu   - Build Rocky + MOFED + NVIDIA (rocky-gpu.qcow2)"
	@echo "  make all   - Build all images"
	@echo "  make clean - Clean build output"
	@echo "  make help  - Show detailed help"
help:
	@echo "Usage:"
	@echo "  make [target] [DRYRUN=1]"
	@echo ""
	@echo "Targets:"
	@echo "  cpu     Build Rocky + MOFED image"
	@echo "  gpu     Build Rocky + MOFED + NVIDIA image"
	@echo "  all     Build all images (default)"
	@echo "  clean   Remove all build artifacts"
	@echo "  list    List available targets"
	@echo "  help    Show this help message"
	@echo ""
	@echo "Options:"
	@echo "  DRYRUN=1   Show commands that would be executed, but don't run them"

cpu: check-deps clean OVMF_VARS.fd SIZE_VARS.fd
ifeq ($(DRYRUN),1)
	@echo "[DRYRUN] packer build rocky-cpu"
	@echo "${PACKER} init rocky9.pkr.hcl"
	@echo "${PACKER} build -only=rocky-cpu.qemu.rocky9 ..."
else
	${PACKER} init rocky9.pkr.hcl && ${PACKER} build \
		-only=rocky-cpu.qemu.rocky9 \
		-var architecture=${ARCH} \
		-var timeout=${TIMEOUT} \
		-var ovmf_suffix=${OVMF_SFX} \
		rocky9.pkr.hcl
endif

gpu: check-deps clean OVMF_VARS.fd SIZE_VARS.fd
ifeq ($(DRYRUN),1)
	@echo "[DRYRUN] packer build rocky-gpu"
	@echo "${PACKER} init rocky9.pkr.hcl"
	@echo "${PACKER} build -only=rocky-gpu.qemu.rocky9 ..."
else
	${PACKER} init rocky9.pkr.hcl && ${PACKER} build \
		-only=rocky-gpu.qemu.rocky9 \
		-var architecture=${ARCH} \
		-var timeout=${TIMEOUT} \
		-var ovmf_suffix=${OVMF_SFX} \
		rocky9.pkr.hcl
endif

clean:
	${RM} -rf *.fd output-rocky9 rocky9.tar.gz
