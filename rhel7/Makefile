PACKER ?= packer
ISO ?= ${RHEL7_ISO_PATH}

.PHONY: all clean

all: rhel7.tar.gz

rhel7.tar.gz: clean
	sudo ${PACKER} init rhel7.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build -var "rhel7_iso_path=${ISO}" rhel7.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu rhel7.tar.gz
