PACKER ?= packer
export PACKER_LOG ?= 0
SUDO ?= sudo -E

.PHONY: all clean check-deps

all: centos7.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos7.tar.gz: clean check-deps
	${SUDO} ${PACKER} init centos7.pkr.hcl && ${SUDO} ${PACKER} build centos7.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-centos7 centos7.tar.gz
