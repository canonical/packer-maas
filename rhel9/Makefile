PACKER ?= packer
PACKER_LOG ?= 0
SUDO ?= sudo
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rhel9.tar.gz

check-deps:
	@if [ $(shell lsb_release -sr|cut -d. -f1) -le 20 ];then \
		dpkg -s libnbd0 nbdkit packer fuse2fs > /dev/null; \
	elif [ $(shell lsb_release -sr|cut -d. -f1) -gt 20 ];then \
		dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null; \
	fi

rhel9.tar.gz: check-deps clean http/rhel9.ks
	${SUDO} ${PACKER} init rhel9.pkr.hcl && ${SUDO} ${PACKER} build -var "rhel9_iso_path=${ISO}" rhel9.pkr.hcl

http/rhel9.ks: http/rhel9.ks.in
	envsubst < $< | tee $@

clean:
	${SUDO} ${RM} -rf output-rhel9 rhel9.tar.gz http/rhel9.ks
