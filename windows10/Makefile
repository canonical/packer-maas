#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG

.PHONY: all clean

all: win10.dd.gz

$(eval $(call check_packages_deps))

win10.dd.gz:
	${PACKER} init . && ${PACKER} build .

clean:
	${RM} -rf output-win10 win10.dd.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
