PACKER ?= packer
ISO ?= SLE-15-SP4-Full-x86_64-GM-Media1.iso

.PHONY: all clean

all: sles15.tar.gz

sles15.tar.gz: clean
	sudo ${PACKER} init sles.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build -var "sles15_iso_path=${ISO}" -on-error=ask sles.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-sles15 sles15.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .
