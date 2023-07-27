PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rocky8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky8.tar.gz: check-deps clean http/rocky.ks
	${SUDO} ${PACKER} init rocky8.pkr.hcl && ${SUDO} ${PACKER} build rocky8.pkr.hcl

http/rocky.ks: http/rocky.ks.in
	envsubst < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-rocky8 rocky8.tar.gz http/rocky.ks
