PACKER ?= packer
PACKER_LOG ?= 0

export PACKER_LOG KS_PROXY

.PHONY: all clean check-deps

all: centos7.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs > /dev/null

centos7.tar.gz: clean check-deps http/centos7.ks
	${PACKER} init centos7.pkr.hcl && ${PACKER} build centos7.pkr.hcl

http/centos7.ks: http/centos7.ks.in
	envsubst '$${KS_PROXY}' < $< | tee $@

clean:
	${RM} -rf output-centos7 centos7.tar.gz http/centos7.ks

.INTERMEDIATE: http/centos7.ks
