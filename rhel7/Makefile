PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo
ISO ?= ${RHEL7_ISO_PATH}

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rhel7.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel7.tar.gz: check-deps clean http/rhel7.ks
	${SUDO} ${PACKER} init rhel7.pkr.hcl && ${SUDO} ${PACKER} build -var "rhel7_iso_path=${ISO}" rhel7.pkr.hcl

http/rhel7.ks: http/rhel7.ks.in
	envsubst < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-rhel7 rhel7.tar.gz
