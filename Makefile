.PHONY: default tar

FULL_NAME := packer-maas-$(shell git describe --dirty)

default:
	$(error Change your working directory to the image name you want to build!)

tar:
	git ls-files --recurse-submodules LICENSE vmware-esxi centos* rhel* | \
	tar -cJf $(FULL_NAME).tar.xz --transform="s,^,$(FULL_NAME)/," -T -
