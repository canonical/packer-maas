#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${RHEL8_ISO_PATH}

export PACKER_LOG

.PHONY: all clean

all: rhel8.tar.gz

$(eval $(call check_packages_deps))

rhel8.tar.gz: check-deps clean
	${PACKER} init rhel8.pkr.hcl && ${PACKER} build -var "rhel8_iso_path=${ISO}" rhel8.pkr.hcl

clean:
	${RM} -rf output-rhel8 rhel8.tar.gz
