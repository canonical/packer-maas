PACKER ?= packer
PACKER_LOG ?= 0
ISO ?= rhel-baseos-9.1-x86_64-dvd.iso

export PACKER_LOG KS_PROXY

.PHONY: all clean

all: rhel9.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

rhel9.tar.gz: check-deps clean http/rhel9.ks
	${PACKER} init rhel9.pkr.hcl && ${PACKER} build -var "rhel9_iso_path=${ISO}" rhel9.pkr.hcl

http/rhel9.ks: http/rhel9.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-rhel9 rhel9.tar.gz http/rhel9.ks

.INTERMEDIATE: http/rhel9.ks
