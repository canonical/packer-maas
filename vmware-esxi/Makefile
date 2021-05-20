PACKER ?= packer
ISO ?= ${VMWARE_ESXI_ISO_PATH}

.PHONY: all clean

all: vmware-esxi.dd.gz

vmware-esxi.dd.gz: clean
	sudo PACKER_LOG=1 ${PACKER} build -var "vmware_esxi_iso_path=${ISO}" vmware-esxi.json
	reset

clean:
	sudo ${RM} -rf output-qemu vmware-esxi.dd.gz
