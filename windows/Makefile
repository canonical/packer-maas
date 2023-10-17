PACKER ?= packer
ISO = ${ISO}
VERSION = ${VERSION}

.PHONY: all init clean ${VERSION}

all: windows-server-${VERSION}.dd.gz

virtio-win.iso:
	@if [ ! -f ./virtio-win.iso ]; then\
		echo "Fetching virtio-win ISO...";\
		wget -nv -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O virtio-win.iso;\
	fi

init:
	sudo packer init windows${VERSION}.json.pkr.hcl

windows-server-${VERSION}.dd.gz: clean virtio-win.iso init
	sudo PACKER_LOG=1 ${PACKER} build --var iso_url=${ISO} --var virtio_win_iso=./virtio-win.iso windows${VERSION}.json.pkr.hcl
	reset

clean:
	sudo ${RM} -rf output-windows_${VERSION} windows-server-${VERSION}.dd.gz