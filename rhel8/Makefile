PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${RHEL8_ISO_PATH}

.PHONY: all clean

all: rhel8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel8.tar.gz: check-deps clean
	sudo ${PACKER} init rhel8.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -var "rhel8_iso_path=${ISO}" rhel8.pkr.hcl

clean:
	sudo ${RM} -rf output-rhel8 rhel8.tar.gz
