#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: ol9.tar.gz

$(eval $(call check_packages_deps))

ol9.tar.gz: check-deps clean
	${PACKER} init ol9.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} ol9.pkr.hcl

clean:
	${RM} -rf output-ol9 ol9.tar.gz
