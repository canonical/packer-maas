PACKER ?= packer
export PACKER_LOG ?= 0
SUDO ?= sudo -E

.PHONY: all clean

all: rocky9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky9.tar.gz: check-deps clean
	${SUDO} ${PACKER} init rocky9.pkr.hcl && ${SUDO} ${PACKER} build rocky9.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-rocky9 rocky9.tar.gz
