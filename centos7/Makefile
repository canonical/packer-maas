PACKER ?= packer

.PHONY: all clean check-deps

all: centos7.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos7.tar.gz: clean check-deps
	sudo ${PACKER} init centos7.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build centos7.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-centos7 centos7.tar.gz
