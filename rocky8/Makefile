PACKER ?= packer

.PHONY: all clean

all: rocky8.tar.gz

rocky8.tar.gz: clean
	sudo ${PACKER} init rocky8.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build rocky8.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-qemu rocky8.tar.gz
