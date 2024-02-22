#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
KS_MIRROR ?= http://mirrorlist.centos.org
export PACKER_LOG

.PHONY: all clean

all: centos8.tar.gz

$(eval $(call check_packages_deps))

centos8.tar.gz: check-deps clean 
	${PACKER} init centos8.pkr.hcl && ${PACKER} build centos8.pkr.hcl

clean:
	${RM} -rf output-centos8 centos8.tar.gz 
