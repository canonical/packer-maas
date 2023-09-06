PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo
ISO ?= ${RHEL8_ISO_PATH}

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rhel8.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel8.tar.gz: check-deps clean http/rhel8.ks
	${SUDO} ${PACKER} init rhel8.pkr.hcl && ${SUDO} ${PACKER} build -var "rhel8_iso_path=${ISO}" rhel8.pkr.hcl

http/rhel8.ks: http/rhel8.ks.in
	envsubst '$KS_PROXY' < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-rhel8 rhel8.tar.gz http/rhel8.ks
