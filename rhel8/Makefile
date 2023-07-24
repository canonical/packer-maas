PACKER ?= packer
export PACKER_LOG ?= 0
SUDO ?= sudo
ISO ?= ${RHEL8_ISO_PATH}

.PHONY: all clean

all: rhel8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel8.tar.gz: check-deps clean
	${SUDO} ${PACKER} init rhel8.pkr.hcl && ${SUDO} ${PACKER} build -var "rhel8_iso_path=${ISO}" rhel8.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-rhel8 rhel8.tar.gz
