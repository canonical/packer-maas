#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

ifneq (${KS_MIRROR},)
KS_OS_REPOS := --url="${KS_MIRROR}/os/x86_64"
KS_UPDATES_REPOS := --baseurl="${KS_MIRROR}/updates/x86_64"
KS_EXTRA_REPOS := --baseurl="${KS_MIRROR}/extras/x86_64"
else
KS_OS_REPOS := --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os"
KS_UPDATES_REPOS := --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates"
KS_EXTRA_REPOS := --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=extras"
endif

export PACKER_LOG KS_PROXY KS_OS_REPOS KS_UPDATES_REPOS KS_EXTRA_REPOS

.PHONY: all clean check-deps

all: centos7.tar.gz

$(eval $(call check_packages_deps))

centos7.tar.gz: clean check-deps http/centos7.ks
	${PACKER} init centos7.pkr.hcl && ${PACKER} build centos7.pkr.hcl

http/centos7.ks: http/centos7.ks.in
	envsubst '$${KS_PROXY} $${KS_OS_REPOS} $${KS_UPDATES_REPOS} $${KS_EXTRA_REPOS}' < $< | tee $@

clean:
	${RM} -rf output-centos7 centos7.tar.gz http/centos7.ks

.INTERMEDIATE: http/centos7.ks
