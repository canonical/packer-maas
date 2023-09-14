#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rocky8.tar.gz

check-deps:
	$(call check_packages_deps)

rocky8.tar.gz: check-deps clean http/rocky.ks
	${PACKER} init rocky8.pkr.hcl && ${PACKER} build rocky8.pkr.hcl

http/rocky.ks: http/rocky.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-rocky8 rocky8.tar.gz http/rocky.ks

.INTERMEDIATE: http/rocky.ks
