#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
KS_MIRROR ?= http://mirrorlist.centos.org
export PACKER_LOG KS_PROXY KS_MIRROR

.PHONY: all clean check-deps

all: centos7.tar.gz

$(eval $(call check_packages_deps))

centos7.tar.gz: clean check-deps http/centos7.ks
	${PACKER} init centos7.pkr.hcl && ${PACKER} build centos7.pkr.hcl

http/centos7.ks: http/centos7.ks.in
	envsubst '$${KS_PROXY} $${KS_MIRROR}' < $< | tee $@

clean:
	${RM} -rf output-centos7 centos7.tar.gz http/centos7.ks

.INTERMEDIATE: http/centos7.ks
