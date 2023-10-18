#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
ISO ?= SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2

.PHONY: all clean

all: sles12.tar.gz

$(eval $(call check_packages_deps))

sles12.tar.gz: check-deps clean
	${PACKER} init sles.pkr.hcl && ${PACKER} build -var "sles12_iso_path=${ISO}" -on-error=ask sles.pkr.hcl

clean:
	${RM} -rf output-sles12 sles12.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
