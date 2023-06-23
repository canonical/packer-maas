PACKER ?= packer

.PHONY: all clean

all: rocky9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rocky9.tar.gz: check-deps clean
	sudo ${PACKER} init rocky9.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build rocky9.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-rocky9 rocky9.tar.gz
