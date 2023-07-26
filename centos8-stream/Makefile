PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: centos8-stream.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos8-stream.tar.gz: check-deps clean http/centos8-stream.ks
	${SUDO} ${PACKER} init centos8-stream.pkr.hcl && ${SUDO} ${PACKER} build centos8-stream.pkr.hcl

http/centos8-stream.ks: http/centos8-stream.ks.in
	envsubst < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-centos8-stream centos8-stream.tar.gz
