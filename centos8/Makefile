PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo

.PHONY: all clean

all: centos8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8.tar.gz: check-deps clean
	${SUDO} ${PACKER} init centos8.pkr.hcl && ${PACKER} build centos8.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-centos8 centos8.tar.gz
