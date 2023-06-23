PACKER ?= packer

.PHONY: all clean

all: centos8-stream.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8-stream.tar.gz: check-deps clean
	sudo ${PACKER} init centos8-stream.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build centos8-stream.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-centos8-stream centos8-stream.tar.gz
