PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos6.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos6.tar.gz: check-deps clean http/centos6.ks
	${SUDO} ${PACKER} init centos6.pkr.hcl && ${SUDO} ${PACKER} build centos6.pkr.hcl

http/centos6.ks: http/centos6.ks.in
	envsubst '$KS_PROXY' < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-centos6 centos6.tar.gz http/centos6.ks
