PACKER ?= packer
ISO ?= ${VMWARE_ESXI_ISO_PATH}
VENV := .ve

.PHONY: all lint format clean

all: vmware-esxi.dd.gz

vmware-esxi.dd.gz: clean
	sudo PACKER_LOG=1 ${PACKER} build -var "vmware_esxi_iso_path=${ISO}" vmware-esxi.json
	reset

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
	sudo ${RM} -rf output-qemu vmware-esxi.dd vmware-esxi.dd.gz $(VENV)
