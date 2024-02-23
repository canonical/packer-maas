#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: rocky9.tar.gz

$(eval $(call check_packages_deps))

rocky9.tar.gz: check-deps clean
	${PACKER} init rocky9.pkr.hcl && ${PACKER} build rocky9.pkr.hcl

clean:
	${RM} -rf output-rocky9 rocky9.tar.gz
