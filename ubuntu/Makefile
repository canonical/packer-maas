PACKER ?= packer
export PACKER_LOG ?= 0
SUDO ?= sudo -E

.PHONY: all clean

all: custom-cloudimg.tar.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fuse2fs cloud-image-utils ovmf > /dev/null

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-cloudimg.tar.gz: check-deps clean
	${SUDO} ${PACKER} init . && ${SUDO} ${PACKER} build -only='cloudimg.*' .

custom-ubuntu.tar.gz: check-deps clean seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	${SUDO} ${PACKER} init . && ${SUDO} ${PACKER} build -only=qemu.flat .

custom-ubuntu-lvm.dd.gz: check-deps clean seeds-lvm.iso OVMF_VARS.fd
	${SUDO} ${PACKER} init . && ${SUDO} ${PACKER} build -only=qemu.lvm .

clean:
	${SUDO} ${RM} -rf output-* custom-*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: OVMF_VARS.fd
