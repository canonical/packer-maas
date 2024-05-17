# VMware ESXi Packer Template for MAAS

## Introduction

[MAAS](https://maas.io) has the ability to deploy VMware ESXi as a custom image. MAAS cannot directly deploy the VMware ESXi ISO, a specialized image must be created from the ISO. Canonical has created a Packer template to automatically do this for you.

## Hardware Prerequisites (to create the images)

* A machine running Ubuntu 18.04 or 20.04 with the ability to run KVM virtual machines.
* Dual core x86_64 processor supporting hardware virtualization with at least 8GB of RAM and 32GB of disk space available.

## Package Prerequisites (to create the images)

* build-essential
* fuse2fs
* fusefat
* libnbd0
* libosinfo-bin
* libvirt-daemon
* libvirt-daemon-system
* nbdfuse
* nbdkit
* ovmf
* python3-dev
* python3-pip
* qemu-block-extra
* qemu-system-x86
* qemu-utils
* Packer - Install from [upstream repository](https://developer.hashicorp.com/packer/install), v1.9.0 or newer
* The VMware ESXi installation ISO must be downloaded manually. You can download it [here.](https://www.vmware.com/go/get-free-esxi)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.0 or above

VMware ESXi has a specific set of [hardware requirements](https://www.vmware.com/resources/compatibility/search.php) which are more stringent than MAAS.

## Customizing the Image

The deployment image may be customized by modifying packer-maas/vmware-esxi/KS.CFG see Installation and Upgrade Scripts in the [VMware ESXi installation and Setup manual](https://docs.vmware.com/en/VMware-vSphere/6.7/vsphere-esxi-67-installation-setup-guide.pdf) for more information.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/path/to/VMware-VMvisor-Installer-8.0b-21203435.x86_64.iso
```

Alternatively you can manually run packer. Your current working directory must be in packer-maas/vmware-esxi, where this file is located. Once in packer-maas/vmware-esxi you can generate an image with:

```shell
sudo packer init .
sudo PACKER_LOG=1 packer build -var 'vmware_esxi_iso_path=/path/to/VMware-VMvisor-Installer-8.0b-21203435.x86_64.iso' .
```

Note: vmware-esxi.pkr.hcl is configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or remove the line containing "headless" in vmware-esxi.pkr.hcl.

Installation is non-interactive.

### Makefile Parameters

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

_Note: If using snap-based MAAS, the image to be uploaded needs reside under your home directory._

```shell
maas $PROFILE boot-resources create \
  name='esxi/8.0b' title='VMware ESXi 8.0b' \
  architecture='amd64/generic' filetype='ddgz' \
  content@=vmware-esxi.dd.gz
```
## Default Credentials

The default username is ```root``` and the default password is set to ```password123!```

## Known limitations

### VMWare support

MAAS uses cloning as the mechanism to deploy all supported OS. **This is [explicitly not supported by VMWare since ESXi 7.0 U2](https://kb.vmware.com/s/article/84280)**, as doing so could lead to data corruption if VMFS volumes are shared among hosts cloned using the same image. There's [no known workaround](https://kb.vmware.com/s/article/84349) for this limitation.

This image should be safe for standalone hosts and if you don't use any kind of shared storage.
**Use this image at your own risk**

### Storage

Only datastores may be configured using the devices available on the system. The first 9 partitions of the disk are reserved for VMware ESXi operating system usage.

### Networking

* Bridges - Not supported in VMware ESXi
* Bonds - The following [MAAS](https://maas.io) bond modes are mapped to VMware ESXi NIC team sharing with load balancing as follows:
  * balance-rr - portid
  * active-backup - explicit
  * 802.3ad - iphash, LACP rate and XMIT hash policy settings are ignored.
  * No other bond modes are currently supported.

**WARNING**: VMware ESXi does not allow VMs to use a PortGroup that has a VMK attached to it. All configured devices will have a VMK attached. To use a vSwitch with VMs you must leave a device or alias unconfigured in MAAS.

### libvirt testing

While VMware ESXi does not support running in any virtual machine it is possible to deploy to one. The libvirt machine must be a KVM instance with at least CPU 2 cores and 4GB of RAM. To give VMware ESXi access to hardware virtualization go into machine settings, CPUs, and select 'copy host CPU configuration.' VMware ESXi has no support for libvirt drivers, instead an emulated IDE disk, and an emulated e1000 NIC must be used.
