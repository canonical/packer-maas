define check_packages_deps
_current_deps := libnbd-bin nbdkit packer fuse2fs $(1)
_focal_deps := libnbd0 nbdfuse nbdkit packer fuse2fs $(2)
_rhel_deps := libnbd nbdfuse nbdkit packer fuse2fs $(2)
_short_release := $(shell lsb_release -s)
print-deps:
	@if [ "$(shell which dnf)" ];then \
		dnf list installed $$(_rhel_deps); \
	elif [ $(shell lsb_release -sr|cut -d. -f1) -ge 22 ];then \
		echo $$(_current_deps); \
	else \
		echo $$(_focal_deps); \
	fi

check-deps:
	@if [ "$(shell which dnf)" ];then \
		dnf list installed $$(_rhel_deps) > /dev/null; \
	elif [ $(shell lsb_release -sr|cut -d. -f1) -ge 22 ];then \
		dpkg -s $$(_current_deps) > /dev/null; \
	else \
		dpkg -s $$(_focal_deps) > /dev/null; \
	fi
endef
