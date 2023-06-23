PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso

.PHONY: all clean

all: rhel9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel9.tar.gz: check-deps clean
	sudo ${PACKER} init rhel9.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -var "rhel9_iso_path=${ISO}" rhel9.pkr.hcl

clean:
	sudo ${RM} -rf output-rhel9 rhel9.tar.gz
