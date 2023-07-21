PACKER ?= packer
export PACKER_LOG ?= 0
SUDO ?= sudo -E

.PHONY: all clean

all: centos6.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos6.tar.gz: check-deps clean
	${SUDO} ${PACKER} init centos6.pkr.hcl && ${SUDO} ${PACKER} build centos6.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-centos6 centos6.tar.gz
