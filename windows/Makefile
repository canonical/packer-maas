#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

ISO ?= 
VERSION ?= 2022
BOOT ?= uefi
HEADLESS ?= false

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

http/Autounattend.xml: http/Autounattend.xml.${BOOT}.template
	sed s#@VERSION@#"${TYPE} ${VERSION} ${EDIT}"#g $< > $@
ifneq ($(strip $(PKEY)),)
	sed -i s#@PKEY@#${PKEY}#g $@
	sed -i 's/<!--<ProductKey>/<ProductKey>/;s/<\/ProductKey>-->/<\/ProductKey>/' $@
endif
ifeq ($(strip $(VERSION)),10)
	sed -i 's/<!--<LocalAccounts>/<LocalAccounts>/;s/<\/LocalAccounts>-->/<\/LocalAccounts>/' $@
else ifeq ($(strip $(VERSION)),11)
	sed -i 's/<!--<LocalAccounts>/<LocalAccounts>/;s/<\/LocalAccounts>-->/<\/LocalAccounts>/' $@
endif

.INTERMEDIATE: http/Autounattend.xml

windows: check-deps clean http/Autounattend.xml
	${PACKER} init . && ${PACKER} build -var iso_path=${ISO} -var headless=${HEADLESS} windows.pkr.hcl

clean:
	${RM} -rf output-* windows.dd.gz http/Autounattend.xml
