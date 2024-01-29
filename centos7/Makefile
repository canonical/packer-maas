#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean check-deps

all: centos7.tar.gz

$(eval $(call check_packages_deps))

centos7.tar.gz: clean check-deps
	${PACKER} init centos7.pkr.hcl && ${PACKER} build centos7.pkr.hcl

clean:
	${RM} -rf output-centos7 centos7.tar.gz
