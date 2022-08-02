PACKER ?= packer

.PHONY: all clean

all: centos6.tar.gz

centos6.tar.gz: clean
	sudo ${PACKER} init centos6.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build centos6.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu centos6.tar.gz
