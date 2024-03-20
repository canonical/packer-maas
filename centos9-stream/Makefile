#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: centos9-stream.tar.gz

$(eval $(call check_packages_deps))

centos9-stream.tar.gz: check-deps clean
	${PACKER} init centos9-stream.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} centos9-stream.pkr.hcl

clean:
	${RM} -rf output-centos9-stream centos9-stream.tar.gz
