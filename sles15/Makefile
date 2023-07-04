PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= SLE-15-SP4-Full-x86_64-GM-Media1.iso

.PHONY: all clean

all: sles15.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

sles15.tar.gz: check-deps clean
	sudo ${PACKER} init sles.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -var "sles15_iso_path=${ISO}" -on-error=ask sles.pkr.hcl

clean:
	sudo ${RM} -rf output-sles15 sles15.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
