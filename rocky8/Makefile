#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: rocky8.tar.gz

$(eval $(call check_packages_deps))

rocky8.tar.gz: check-deps clean
	${PACKER} init rocky8.pkr.hcl && ${PACKER} build rocky8.pkr.hcl

clean:
	${RM} -rf output-rocky8 rocky8.tar.gz
