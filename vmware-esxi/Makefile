PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG
SUDO ?= sudo
ISO ?= ${VMWARE_ESXI_ISO_PATH}
VENV := .ve

.PHONY: all lint format clean

all: vmware-esxi.dd.gz

check-deps:
	dpkg -s libnbd-bin nbdkit packer fusefat > /dev/null

vmware-esxi.dd.gz: check-deps clean
	${SUDO} ${PACKER} init vmware-esxi.pkr.hcl && ${SUDO} ${PACKER} build -var "vmware_esxi_iso_path=${ISO}" vmware-esxi.pkr.hcl

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
	${SUDO} ${RM} -rf output-esxi vmware-esxi.dd vmware-esxi.dd.gz $(VENV)
