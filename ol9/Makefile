#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: ol9.tar.gz

check-deps:
	$(call check_packages_deps)

ol9.tar.gz: check-deps clean http/ol9.ks
	${PACKER} init ol9.pkr.hcl && ${PACKER} build ol9.pkr.hcl

http/ol9.ks: http/ol9.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-ol9 ol9.tar.gz http/ol9.ks

.INTERMEDIATE: http/ol9.ks
