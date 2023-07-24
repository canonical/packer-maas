PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo

.PHONY: all clean

all: centos8-stream.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8-stream.tar.gz: check-deps clean
	${SUDO} ${PACKER} init centos8-stream.pkr.hcl && ${SUDO} ${PACKER} build centos8-stream.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-centos8-stream centos8-stream.tar.gz
