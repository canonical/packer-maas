PACKER ?= packer

.PHONY: all clean

all: custom-ubuntu-efi.dd.gz

seeds.iso: user-data meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-ubuntu.dd.gz: clean seeds.iso
	sudo PACKER_LOG=1 ${PACKER} build ubuntu.json && reset

custom-ubuntu-efi.dd.gz: clean seeds.iso OVMF_VARS.fd
	sudo PACKER_LOG=1 ${PACKER} build ubuntu-efi.json && reset

clean:
	sudo ${RM} -rf output-qemu ubuntu*.tar.gz

.VOLATILE: OVMF_VARS.fd
