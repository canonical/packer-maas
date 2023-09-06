PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8.tar.gz: check-deps clean http/centos8.ks
	${SUDO} ${PACKER} init centos8.pkr.hcl && ${PACKER} build centos8.pkr.hcl

http/centos8.ks: http/centos8.ks.in
	envsubst '$KS_PROXY' < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-centos8 centos8.tar.gz http/centos8.ks
