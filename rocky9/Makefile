PACKER ?= packer
PACKER_LOG ?= 0

.PHONY: all clean

all: rocky9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky9.tar.gz: check-deps clean
	sudo ${PACKER} init rocky9.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build rocky9.pkr.hcl

clean:
	sudo ${RM} -rf output-rocky9 rocky9.tar.gz
