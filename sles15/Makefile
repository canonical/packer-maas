PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo
ISO ?= SLE-15-SP4-Full-x86_64-GM-Media1.iso

.PHONY: all clean

all: sles15.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

sles15.tar.gz: check-deps clean
	${SUDO} ${PACKER} init sles.pkr.hcl && ${SUDO} ${PACKER} build -var "sles15_iso_path=${ISO}" -on-error=ask sles.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-sles15 sles15.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
