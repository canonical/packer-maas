PACKER ?= packer

.PHONY: all clean

all: centos9.tar.gz

centos9.tar.gz: clean
	sudo ${PACKER} init centos9.pkr.hcl && PACKER_LOG=1 ${PACKER} build centos9.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-centos9 centos9.tar.gz
