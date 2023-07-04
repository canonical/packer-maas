PACKER ?= packer
PACKER_LOG ?= 0

.PHONY: all clean

all: rocky8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky8.tar.gz: check-deps clean
	sudo ${PACKER} init rocky8.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build rocky8.pkr.hcl

clean:
	sudo ${RM} -rf output-rocky8 rocky8.tar.gz
