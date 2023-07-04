PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= ${RHEL7_ISO_PATH}

.PHONY: all clean

all: rhel7.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel7.tar.gz: check-deps clean
	sudo ${PACKER} init rhel7.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -var "rhel7_iso_path=${ISO}" rhel7.pkr.hcl

clean:
	sudo ${RM} -rf output-rhel7 rhel7.tar.gz
