#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso
TIMEOUT ?= 1h

export PACKER_LOG

.PHONY: all clean

all: rhel9.tar.gz

$(eval $(call check_packages_deps))

rhel9.tar.gz: check-deps clean
	${PACKER} init rhel9.pkr.hcl && ${PACKER} build -var "rhel9_iso_path=${ISO}" -var timeout=${TIMEOUT} rhel9.pkr.hcl

clean:
	${RM} -rf output-rhel9 rhel9.tar.gz
