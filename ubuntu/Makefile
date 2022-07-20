PACKER ?= packer

.PHONY: all clean

all: custom-ubuntu-lvm.dd.gz

lint:
	packer validate -var customize_script=scripts/cloudimg/setup-boot.sh ubuntu-cloudimg.pkr.hcl
	packer fmt -check -diff .

format:
	packer fmt .

seeds-cloudimg.iso: user-data-cloudimg meta-data
	cloud-localds $@ $^

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-ubuntu.tar.gz: clean seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	sudo PACKER_LOG=1 ${PACKER} build ubuntu-flat.json && reset

custom-ubuntu-lvm.dd.gz: clean seeds-lvm.iso OVMF_VARS.fd
	sudo PACKER_LOG=1 ${PACKER} build ubuntu-lvm.json && reset

clean:
	sudo ${RM} -rf output-qemu custom-ubuntu*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
	tar czf $@ -C packages ${notdir $^}

.INTERMEDIATE: OVMF_VARS.fd
