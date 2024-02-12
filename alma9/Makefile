#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: alma9.tar.gz

$(eval $(call check_packages_deps))

alma9.tar.gz: check-deps clean http/alma.ks
	${PACKER} init alma9.pkr.hcl && ${PACKER} build alma9.pkr.hcl

http/alma.ks: http/alma.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-alma9 alma9.tar.gz http/alma.ks

.INTERMEDIATE: http/alma.ks
