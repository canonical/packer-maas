#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
ISO ?= ${VMWARE_ESXI_ISO_PATH}
VENV := .ve
TIMEOUT ?= 1h

.PHONY: all lint format clean

all: vmware-esxi.dd.gz

$(eval $(call check_packages_deps,fusefat,fusefat ))

scripts.tar.xz:
	export TMP_DIR=$$(mktemp -d /tmp/packer-maas-XXXX);\
	export SCRIPT_DIR=$$TMP_DIR/altbootbank;\
	mkdir -p $${SCRIPT_DIR};\
	cp -rv maas $${SCRIPT_DIR}/ ;\
	python3 -m pip install -r requirements.txt --no-compile --target $${SCRIPT_DIR}/maas ;\
	find $${SCRIPT_DIR} -name __pycache__ -type d -or -name *.so | xargs rm -rf ;\
	tar cJf $@ --group=0 --owner=0 -C $${SCRIPT_DIR} .

vmware-esxi.dd.gz: check-deps clean scripts.tar.xz
	${PACKER} init vmware-esxi.pkr.hcl && ${PACKER} build -var "vmware_esxi_iso_path=${ISO}" -var timeout=${TIMEOUT} vmware-esxi.pkr.hcl

$(VENV): requirements-dev.txt requirements.txt
	python3 -m venv --system-site-packages --clear $@
	$(VENV)/bin/pip install $(foreach r,$^,-r $(r))

lint: $(VENV)
	$(eval py_files := $(shell grep -R -m1 -l '#!/usr/bin/env python' maas/ curtin/))
	$(VENV)/bin/isort --check-only --diff $(py_files)
	$(VENV)/bin/black --check $(py_files)
	$(VENV)/bin/flake8 --ignore E203,W503 $(py_files)

format: $(VENV)
	$(eval py_files := $(shell grep -R -m1 -l '#!/usr/bin/env python' maas/ curtin/))
	$(VENV)/bin/isort $(py_files)
	$(VENV)/bin/black -q $(py_files)

clean:
	${RM} -rf output-esxi vmware-esxi.dd vmware-esxi.dd.gz \
		scripts.tar.xz $(VENV)

.INTERMEDIATE: scripts.tar.xz
