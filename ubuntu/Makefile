PACKER ?= packer

.PHONY: all clean

all: custom-ubuntu-lvm.dd.gz

lint:
	packer validate -var customize_script=scripts/cloudimg/setup-boot.sh ubuntu-cloudimg.pkr.hcl
	packer fmt -check -diff .

format:
	packer fmt .

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-ubuntu.tar.gz: clean seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	sudo ${PACKER} init ubuntu-flat.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build ubuntu-flat.pkr.hcl && reset

custom-ubuntu-lvm.dd.gz: clean seeds-lvm.iso OVMF_VARS.fd
	sudo ${PACKER} init ubuntu-lvm.pkr.hcl && sudo PACKER_LOG=1 ${PACKER} build ubuntu-lvm.pkr.hcl && reset

clean:
	sudo ${RM} -rf output-qemu custom-ubuntu*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
	tar czf $@ -C packages ${notdir $^}

.INTERMEDIATE: OVMF_VARS.fd
