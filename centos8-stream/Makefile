#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: centos8-stream.tar.gz

$(eval $(call check_packages_deps))

centos8-stream.tar.gz: check-deps clean
	${PACKER} init centos8-stream.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} centos8-stream.pkr.hcl

clean:
	${RM} -rf output-centos8-stream centos8-stream.tar.gz
