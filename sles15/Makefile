#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
ISO ?= SLE-15-SP4-Full-x86_64-GM-Media1.iso

.PHONY: all clean

all: sles15.tar.gz

$(eval $(call check_packages_deps))

sles15.tar.gz: check-deps clean
	${PACKER} init sles.pkr.hcl && ${PACKER} build -var "sles15_iso_path=${ISO}" -on-error=ask sles.pkr.hcl

clean:
	${RM} -rf output-sles15 sles15.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
