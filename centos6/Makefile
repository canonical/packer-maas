PACKER ?= packer

.PHONY: all clean

all: centos6.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos6.tar.gz: check-deps clean
	sudo ${PACKER} init centos6.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build centos6.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-centos6 centos6.tar.gz
