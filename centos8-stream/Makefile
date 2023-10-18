#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos8-stream.tar.gz

$(eval $(call check_packages_deps))

centos8-stream.tar.gz: check-deps clean http/centos8-stream.ks
	${PACKER} init centos8-stream.pkr.hcl && ${PACKER} build centos8-stream.pkr.hcl

http/centos8-stream.ks: http/centos8-stream.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-centos8-stream centos8-stream.tar.gz http/centos8-stream.ks

.INTERMEDIATE: http/centos8-stream.ks
