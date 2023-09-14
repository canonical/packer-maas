#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${RHEL7_ISO_PATH}

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rhel7.tar.gz

check-deps:
	$(call check_packages_deps)

rhel7.tar.gz: check-deps clean http/rhel7.ks
	${PACKER} init rhel7.pkr.hcl && ${PACKER} build -var "rhel7_iso_path=${ISO}" rhel7.pkr.hcl

http/rhel7.ks: http/rhel7.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-rhel7 rhel7.tar.gz http/rhel7.ks

.INTERMEDIATE: http/rhel7.ks
