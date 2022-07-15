PACKER ?= packer

.PHONY: all clean

all: rocky9.tar.gz

rocky9.tar.gz: clean
	sudo PACKER_LOG=1 ${PACKER} build rocky9.json
	reset

clean:
	sudo ${RM} -rf output-qemu rocky9.tar.gz
