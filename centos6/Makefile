#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: centos6.tar.gz

$(eval $(call check_packages_deps))

centos6.tar.gz: check-deps clean
	${PACKER} init centos6.pkr.hcl && ${PACKER} build centos6.pkr.hcl

clean:
	${RM} -rf output-centos6 centos6.tar.gz
