#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos9-stream.tar.gz

$(eval $(call check_packages_deps))

centos9-stream.tar.gz: check-deps clean http/centos9-stream.ks
	${PACKER} init centos9-stream.pkr.hcl && ${PACKER} build centos9-stream.pkr.hcl

http/centos9-stream.ks: http/centos9-stream.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-centos9-stream centos9-stream.tar.gz http/centos9-stream.ks

.INTERMEDIATE: http/centos9-stream.ks
