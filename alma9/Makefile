#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: alma9.tar.gz

$(eval $(call check_packages_deps))

alma9.tar.gz: check-deps clean
	${PACKER} init alma9.pkr.hcl && ${PACKER} build -var timeout=${TIMEOUT} alma9.pkr.hcl

clean:
	${RM} -rf output-alma9 alma9.tar.gz
