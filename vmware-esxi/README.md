# VMware ESXi Packer Template for MAAS

## Introduction
MAAS 2.5 and above has the ability to deploy VMware ESXi as a custom image. MAAS cannot directly deploy the VMware ESXi ISO, a specialized image must be created from the ISO. Canonical has created a Packer template to automatically do this for you.

## Prerequisites (to create the images)

* A machine running Ubuntu 18.04+
* [Packer.](https://www.packer.io/intro/getting-started/install.html)
* The VMware ESXi installation ISO must be downloaded manually. You can download it [here.](https://www.vmware.com/go/get-free-esxi)

## Customizing the Image
The deployment image may be customized by modifying packer-maas/vmware-esxi/http/vmware-esxi-ks.cfg see Installation and Upgrade Scripts in the [VMware ESXi installation and Setup manual](https://docs.vmware.com/en/VMware-vSphere/6.7/vsphere-esxi-67-installation-setup-guide.pdf) for more information.

## Building an image
Before you begin make sure the nbd kernel module is loaded.
```
$ sudo modprobe nbd
```

Your current working directory must be in packer-maas/vmware-esxi, where this file is located. Once in packer-maas/vmware-esxi you can generate an image with:
```
$ sudo packer build -var 'vmware_esxi_iso_path=/path/to/VMware-VMvisor-Installer-6.7.0-8169922.x86_64.iso' vmware-esxi.json
```

Note: Note: If you are building the image over SSH or a headless environment you must add [headless=True](https://www.packer.io/docs/builders/vmware-iso.html#headless) to vmware-esxi.json.
Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create name='esxi/6.7' title='VMware ESXi 6.7' architecture='amd64/generic' filetype='ddgz' content@=vmware-esxi.dd.gz
```

## Requirements
VMware ESXi has a specific set of [hardware requirements](https://www.vmware.com/resources/compatibility/search.php) which are more stringent then MAAS.

The machine building the deployment image must be a GNU/Linux host with a dual core x86_64 processor supporting hardware virtualization with at least 4GB of RAM and 10GB of disk space available. Additionally the qemu-kvm and qemu-utils packages must be installed on the build system.

### libvirt testing
While VMware ESXi does not support running in any virtual machine it is possible to deploy to one. The libvirt machine must be a KVM instance with at least CPU 2 cores and 4GB of RAM. To give VMware ESXi access to hardware virtualization go into machine settings, CPUs, and select 'copy host CPU configuration.' VMware ESXi has no support for libvirt drivers, instead an emulated IDE disk, and an emulated e1000 NIC must be used.

## Known limitations

### Storage
Only datastores may be configured using the devices available on the system. The first 9 partitions of the disk are reserved for VMware ESXi operating system usage.

### Networking
* Bridges - Not supported in VMware ESXi
* Bonds - The following MAAS bond modes are mapped to VMware ESXi NIC team sharing with load balancing as follows:
  * balance-rr - portid
  * active-backup - explicit
  * 802.3ad - iphash, LACP rate and XMIT hash policy settings are ignored.
  * No other bond modes are currently supported.

**WARNING**: VMware ESXi does not allow VMs to use a PortGroup that has a VMK attached to it. All configured devices will have a VMK attached. To use a vSwitch with VMs you must leave a device or alias unconfigured in MAAS.

### Image fails to build due to qemu-nbd error
If the image fails to build due to a qemu-nbd error try disconnecting the device with
```
$ sudo qemu-nbd -d /dev/nbd4
```
