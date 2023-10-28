#!/usr/bin/make -f

include ../scripts/check.mk

ISO_PATH ?=
WINDOWS_IMAGE ?= default_image
PRODUCT_KEY ?=

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: windows10.dd.gz

$(eval $(call check_packages_deps))

windows10.dd.gz: check-deps clean
	${PACKER} init . && ${PACKER} build .

custom-windows10.dd.gz: check-deps clean
	./scripts/setup.sh "$(ISO_PATH)" "$(WINDOWS_IMAGE)" "$(PRODUCT_KEY)"
	${PACKER} init . && ${PACKER} build .

clean:
	${RM} -rf output-win10 win10.dd.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
