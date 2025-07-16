#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
KS_MIRROR ?= https://vault.centos.org
TIMEOUT ?= 1h
export PACKER_LOG

.PHONY: all clean

all: centos8.tar.gz

$(eval $(call check_packages_deps))

centos8.tar.gz: check-deps clean 
	${PACKER} init centos8.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} centos8.pkr.hcl

clean:
	${RM} -rf output-centos8 centos8.tar.gz 
