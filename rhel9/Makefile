PACKER ?= packer
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso

.PHONY: all clean

all: rhel9.tar.gz

rhel9.tar.gz: clean
	sudo ${PACKER} init rhel9.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build -var "rhel9_iso_path=${ISO}" rhel9.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-rhel9 rhel9.tar.gz
