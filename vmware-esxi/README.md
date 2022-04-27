# VMware ESXi Packer Template for MAAS

## Introduction
[MAAS](https://maas.io) 2.5 and above has the ability to deploy VMware ESXi as a custom image. [MAAS](https://maas.io) cannot directly deploy the VMware ESXi ISO, a specialized image must be created from the ISO. Canonical has created a Packer template to automatically do this for you.

## Prerequisites (to create the images)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* Python Pip
* [Packer](https://www.packer.io/intro/getting-started/install.html)
* The VMware ESXi installation ISO must be downloaded manually. You can download it [here.](https://www.vmware.com/go/get-free-esxi)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.5 or above, [MAAS](https://maas.io) 2.6 required for storage configuration

## Customizing the Image
The deployment image may be customized by modifying packer-maas/vmware-esxi/KS.CFG see Installation and Upgrade Scripts in the [VMware ESXi installation and Setup manual](https://docs.vmware.com/en/VMware-vSphere/6.7/vsphere-esxi-67-installation-setup-guide.pdf) for more information.

## Building an image
You can easily build the image using the Makefile:

```
$ make ISO=/path/to/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
```

Alternatively you can manually run packer. Your current working directory must be in packer-maas/vmware-esxi, where this file is located. Once in packer-maas/vmware-esxi you can generate an image with:
```
$ sudo PACKER_LOG=1 packer build -var 'vmware_esxi_iso_path=/path/to/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso' vmware-esxi.json
```

Note: vmware-esxi.json is configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or remove the line containing "headless" in vmware-esxi.json.

Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create name='esxi/6.7' title='VMware ESXi 6.7' architecture='amd64/generic' filetype='ddgz' content@=vmware-esxi.dd.gz
```

## Requirements
VMware ESXi has a specific set of [hardware requirements](https://www.vmware.com/resources/compatibility/search.php) which are more stringent than MAAS.

The machine building the deployment image must be a GNU/Linux host with a dual core x86_64 processor supporting hardware virtualization with at least 4GB of RAM and 10GB of disk space available. Additionally the qemu-kvm and qemu-utils packages must be installed on the build system.

### libvirt testing
While VMware ESXi does not support running in any virtual machine it is possible to deploy to one. The libvirt machine must be a KVM instance with at least CPU 2 cores and 4GB of RAM. To give VMware ESXi access to hardware virtualization go into machine settings, CPUs, and select 'copy host CPU configuration.' VMware ESXi has no support for libvirt drivers, instead an emulated IDE disk, and an emulated e1000 NIC must be used.

## Known limitations

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

### Image fails to build due to qemu-nbd error
If the image fails to build due to a qemu-nbd error try disconnecting the device with
```
$ sudo qemu-nbd -d /dev/nbd4
```
