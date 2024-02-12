#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: alma8.tar.gz

$(eval $(call check_packages_deps))

alma8.tar.gz: check-deps clean
	${PACKER} init alma8.pkr.hcl && ${PACKER} build alma8.pkr.hcl

clean:
	${RM} -rf output-alma8 alma8.tar.gz
