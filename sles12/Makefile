PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo
ISO ?= SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2

.PHONY: all clean

all: sles12.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

sles12.tar.gz: check-deps clean
	${SUDO} ${PACKER} init sles.pkr.hcl && ${SUDO} ${PACKER} build -var "sles12_iso_path=${ISO}" -on-error=ask sles.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-sles12 sles12.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
