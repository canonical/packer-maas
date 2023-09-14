define check_packages_deps
	@if [ $(shell lsb_release -sr|cut -d. -f1) -ge 22 ];then \
		dpkg -s libnbd-bin nbdkit packer fuse2fs $(1) > /dev/null; \
	else \
		dpkg -s libnbd0 nbdkit packer fuse2fs $(2)> /dev/null; \
	fi
endef
