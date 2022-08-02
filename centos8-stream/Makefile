PACKER ?= packer

.PHONY: all clean

all: centos8-stream.tar.gz

centos8-stream.tar.gz: clean
	sudo ${PACKER} init centos8-stream.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build centos8-stream.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu centos8-stream.tar.gz
