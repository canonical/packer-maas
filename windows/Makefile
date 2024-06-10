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

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

.PHONY: all clean

all: windows

$(eval $(call check_packages_deps,cloud-image-utils ovmf,cloud-image-utils ovmf))

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.fd
	cp -v $< $@

http/Autounattend.xml: http/Autounattend.xml.${BOOT}.template
	sed s#@VERSION@#"${TYPE} ${VERSION} ${EDIT}"#g $< > $@
ifneq ($(strip $(PKEY1)),)
	sed -i s#@PKEY@#${PKEY}#g $@
	sed -i 's/<!--<ProductKey>/<ProductKey>/;s/<\/ProductKey>-->/<\/ProductKey>/' $@
endif
ifeq ($(strip $(VERSION)),10)
	sed -i 's/<!--<LocalAccounts>/<LocalAccounts>/;s/<\/LocalAccounts>-->/<\/LocalAccounts>/' $@
else ifeq ($(strip $(VERSION)),11)
	sed -i 's/<!--<LocalAccounts>/<LocalAccounts>/;s/<\/LocalAccounts>-->/<\/LocalAccounts>/' $@
endif

extra_drivers:
	mkisofs -o drivers.iso -V 'Extra Drivers' -input-charset utf-8 drivers

.INTERMEDIATE: extra_drivers http/Autounattend.xml

windows: check-deps clean extra_drivers http/Autounattend.xml OVMF_VARS.fd
	${PACKER} init . && ${PACKER} build -var iso_path=${ISO} \
			-var headless=${HEADLESS} \
			-var ovmf_suffix=${OVMF_SFX} \
			windows.pkr.hcl

clean:
	${RM} -rf output-* windows.tar.gz http/Autounattend.xml \
	drivers.iso OVMF_VARS.fd
