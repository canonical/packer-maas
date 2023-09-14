#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos8.tar.gz

check-deps:
	$(call check_packages_deps)

centos8.tar.gz: check-deps clean http/centos8.ks
	${PACKER} init centos8.pkr.hcl && ${PACKER} build centos8.pkr.hcl

http/centos8.ks: http/centos8.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-centos8 centos8.tar.gz http/centos8.ks

.INTERMEDIATE: http/centos8.ks
