PACKER ?= packer
PACKER_LOG ?= 0

.PHONY: all clean

all: centos8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8.tar.gz: check-deps clean
	sudo ${PACKER} init centos8.pkr.hcl && PACKER_LOG=${PACKER_LOG} ${PACKER} build centos8.pkr.hcl

clean:
	sudo ${RM} -rf output-centos8 centos8.tar.gz
