PACKER ?= packer
ISO ?= ${RHEL8_ISO_PATH}

.PHONY: all clean

all: rhel8.tar.gz

rhel8.tar.gz: clean
	sudo ${PACKER} init rhel8.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build -var "rhel8_iso_path=${ISO}" rhel8.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu rhel8.tar.gz
