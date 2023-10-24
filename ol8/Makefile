#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: ol8.tar.gz

check-deps:
	$(call check_packages_deps)

ol8.tar.gz: check-deps clean http/ol8.ks
	${PACKER} init ol8.pkr.hcl && ${PACKER} build ol8.pkr.hcl

http/ol8.ks: http/ol8.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-ol8 ol8.tar.gz http/ol8.ks

.INTERMEDIATE: http/ol8.ks
