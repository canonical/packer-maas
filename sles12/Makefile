PACKER ?= packer
ISO ?= SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2

.PHONY: all clean

all: sles12.tar.gz

sles12.tar.gz: clean
	sudo ${PACKER} init sles.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build -var "sles12_iso_path=${ISO}" -on-error=ask sles.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-sles12 sles12.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
