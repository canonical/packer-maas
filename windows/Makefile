#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

ISO ?=
VHDX ?=
VERSION ?= 2022
HEADLESS ?= false
FORMAT ?= ISO
TIMEOUT ?= 1h

ifeq ($(strip $(VERSION)),10)
	TYPE = Windows
	EDIT ?= PRO
else ifeq ($(strip $(VERSION)),11)
	TYPE = Windows
	EDIT ?= PRO
	USE_TPM ?= yes
else ifeq ($(strip $(VERSION)),2025)
	TYPE = Windows Server
	EDIT ?= SERVERSTANDARD
else
	TYPE = Windows Server
	EDIT ?= SERVERSTANDARD
endif

ifneq ($(strip $(VHDX)),)
	FORMAT ?= VHDX
endif

ifeq ($(wildcard /usr/share/OVMF/OVMF_CODE.fd),)
	OVMF_SFX ?= _4M
else
	OVMF_SFX ?=
endif

.PHONY: all clean

all: windows

$(eval $(call check_packages_deps,cloud-image-utils,genisoimage,swtpm ovmf,cloud-image-utils ovmf,genisoimage,swtpm))

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS*.ms.fd
	cp -v $< $@

http/Autounattend.xml: http/Autounattend.xml.${FORMAT}.template
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

extra_drivers:
	mkisofs -o drivers.iso -V 'Extra Drivers' -input-charset utf-8 drivers

.INTERMEDIATE: extra_drivers http/Autounattend.xml

windows: check-deps clean extra_drivers http/Autounattend.xml OVMF_VARS.fd
ifeq ($(strip $(VERSION)),11)
	mkdir -p /tmp/swtpm; \
	swtpm socket --daemon --tpm2 --tpmstate dir=/tmp/swtpm --ctrl type=unixio,path=/tmp/swtpm/swtpm-sock --log level=10
endif
ifneq ($(strip $(VHDX)),)
	qemu-img convert -p -O raw ${VHDX} windows_builder.img; \
	scripts/setup-nbd windows_builder.img; \
	TMP_DIR=$$(mktemp -d /tmp/packer-maas-XXXX); \
	nbd=$$(cat /tmp/nbd.lock); \
	pnum=$$(lsblk -l $${nbd} | grep -c part); \
	echo 'Adding unattend.xml to image...'; \
	mount -t ntfs $${nbd}p$${pnum} $${TMP_DIR}; \
	mkdir -pv $${TMP_DIR}/Windows/Panther/; \
	cp -v ./http/Autounattend.xml $${TMP_DIR}/Windows/Panther/unattend.xml; \
	sync -f $${TMP_DIR}/Windows/Panther/; \
	umount $${TMP_DIR}; \
	qemu-nbd -d $${nbd}; \
	rmdir $${TMP_DIR};
	${PACKER} init . && ${PACKER} build -var iso_path=windows_builder.img \
			-var headless=${HEADLESS} \
			-var ovmf_suffix=${OVMF_SFX} \
			-var timeout=${TIMEOUT} \
			-var is_vhdx=true \
			-var disk_size=64G \
			windows.pkr.hcl
else
	${PACKER} init . && ${PACKER} build -var iso_path=${ISO} \
			-var headless=${HEADLESS} \
			-var ovmf_suffix=${OVMF_SFX} \
			-var is_vhdx=false \
			-var timeout=${TIMEOUT} \
			-var use_tpm=${USE_TPM} \
			windows.pkr.hcl
endif

clean:
	${RM} -rf output-* windows.dd.gz http/Autounattend.xml \
	drivers.iso windows_builder.img OVMF_VARS.fd
