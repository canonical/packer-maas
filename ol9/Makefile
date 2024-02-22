#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: ol9.tar.gz

$(eval $(call check_packages_deps))

ol9.tar.gz: check-deps clean
	${PACKER} init ol9.pkr.hcl && ${PACKER} build ol9.pkr.hcl

clean:
	${RM} -rf output-ol9 ol9.tar.gz
