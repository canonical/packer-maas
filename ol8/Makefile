#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: ol8.tar.gz

$(eval $(call check_packages_deps))

ol8.tar.gz: check-deps clean
	${PACKER} init ol8.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} ol8.pkr.hcl

clean:
	${RM} -rf output-ol8 ol8.tar.gz
