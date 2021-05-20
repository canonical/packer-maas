PACKER ?= packer

.PHONY: all clean

all: centos8.tar.gz

centos8.tar.gz: clean
	sudo PACKER_LOG=1 ${PACKER} build centos8.json
	reset

clean:
	sudo ${RM} -rf output-qemu centos8.tar.gz
