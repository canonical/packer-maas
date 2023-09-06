PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rocky9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky9.tar.gz: check-deps clean http/rocky.ks
	${SUDO} ${PACKER} init rocky9.pkr.hcl && ${SUDO} ${PACKER} build rocky9.pkr.hcl

http/rocky.ks: http/rocky.ks.in
	envsubst '$KS_PROXY' < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-rocky9 rocky9.tar.gz http/rocky.ks
