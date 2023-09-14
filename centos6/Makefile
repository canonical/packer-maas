#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos6.tar.gz

check-deps:
	$(call check_packages_deps)

centos6.tar.gz: check-deps clean http/centos6.ks
	${PACKER} init centos6.pkr.hcl && ${PACKER} build centos6.pkr.hcl

http/centos6.ks: http/centos6.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-centos6 centos6.tar.gz http/centos6.ks

.INTERMEDIATE: http/centos6.ks
