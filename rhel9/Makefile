PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso

.PHONY: all clean

all: rhel9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel9.tar.gz: check-deps clean
	${SUDO} ${PACKER} init rhel9.pkr.hcl && ${SUDO} ${PACKER} build -var "rhel9_iso_path=${ISO}" rhel9.pkr.hcl

clean:
	${SUDO} ${RM} -rf output-rhel9 rhel9.tar.gz
