#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rocky9.tar.gz

$(eval $(call check_packages_deps))

rocky9.tar.gz: check-deps clean http/rocky.ks
	${PACKER} init rocky9.pkr.hcl && ${PACKER} build rocky9.pkr.hcl

http/rocky.ks: http/rocky.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-rocky9 rocky9.tar.gz http/rocky.ks

.INTERMEDIATE: http/rocky.ks
