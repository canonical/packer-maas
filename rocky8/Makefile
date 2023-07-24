PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo

.PHONY: all clean

all: rocky8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky8.tar.gz: check-deps clean
	${SUDO} ${PACKER} init rocky8.pkr.hcl && ${SUDO} ${PACKER} build rocky8.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-rocky8 rocky8.tar.gz
