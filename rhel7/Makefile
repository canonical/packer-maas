#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${RHEL7_ISO_PATH}

export PACKER_LOG

.PHONY: all clean

all: rhel7.tar.gz

$(eval $(call check_packages_deps))

rhel7.tar.gz: check-deps clean
	${PACKER} init rhel7.pkr.hcl && ${PACKER} build -var "rhel7_iso_path=${ISO}" rhel7.pkr.hcl

clean:
	${RM} -rf output-rhel7 rhel7.tar.gz 
