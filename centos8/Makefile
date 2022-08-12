PACKER ?= packer

.PHONY: all clean

all: centos8.tar.gz

centos8.tar.gz: clean
	sudo ${PACKER} init centos8.pkr.hcl && PACKER_LOG=1 ${PACKER} build centos8.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu centos8.tar.gz
