#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

ISO ?= 
VERSION ?= 2022
BOOT ?= uefi

ifeq ($(strip $(VERSION)),10)
	TYPE = Windows
	EDIT ?= PRO
else ifeq ($(strip $(VERSION)),11)
	TYPE = Windows
	EDIT ?= PRO
else
	TYPE = Windows Server
	EDIT ?= SERVERSTANDARD
endif

.PHONY: all clean

all: windows

$(eval $(call check_packages_deps,cloud-image-utils ovmf,cloud-image-utils ovmf))

windows: check-deps clean
	sed s#@VERSION@#"${TYPE} ${VERSION} ${EDIT}"#g http/Autounattend.xml.${BOOT}.template > http/Autounattend.xml

ifneq ($(strip $(PKEY)),)
	sed -i s#@PKEY@#${PKEY}#g http/Autounattend.xml
	sed -i 's/<!--<ProductKey>/<ProductKey>/;s/<\/ProductKey>-->/<\/ProductKey>/' http/Autounattend.xml
endif
	${PACKER} build -var iso_path=${ISO} windows.json

clean:
	${RM} -rf output-* windows.dd.gz http/Autounattend.xml
