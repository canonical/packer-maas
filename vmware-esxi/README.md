# VMware ESXi Packer Template for MAAS

## Prerequisites

The VMware ESXi installation ISO must be downloaded manually. You can download it [here.](https://www.vmware.com/go/get-free-esxi)

## Building an image
Your current working directory must be in packer-maas/vmware-esxi, where this file is located. Once in packer-maas/vmware-esxi you can generate an image with:
```
$ sudo packer build -var 'vmware_esxi_iso_path=/path/to/VMware-VMvisor-Installer-6.7.0-8169922.x86_64.iso' vmware-esxi.json
```
Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create name='vmware-esxi-6.7' title='VMware ESXi 6.7' architecture='amd64/generic' filetype='ddgz' content@=vmware-esxi.dd.gz
```

## Customization
The deployment image may be customized by modifying packer-maas/vmware-esxi/http/vmware-esxi-ks.cfg see Installation and Upgrade Scripts in the [VMware ESXi installation and Setup manual](https://docs.vmware.com/en/VMware-vSphere/6.7/vsphere-esxi-67-installation-setup-guide.pdf) for more information.

## Requirements
VMware ESXi has a specific set of [hardware requirements](https://www.vmware.com/resources/compatibility/search.php) which are more stringent then MAAS.

The machine building the deployment image must be a GNU/Linux host with a dual core x86_64 processor supporting hardware virtualization with at least 4GB of RAM and 10GB of disk space available. Additionally the qemu-kvm and qemu-utils packages must be installed on the build system.

### libvirt testing
While VMware ESXi does not support running in any virtual machine it is possible to deploy to one. The libvirt machine must be a KVM instance with at least CPU 2 cores and 4GB of RAM. To give VMware ESXi access to hardware virtualization go into machine settings, CPUs, and select 'copy host CPU configuration.' VMware ESXi has no support for libvirt drivers, instead an emulated IDE disk, and an emulated e1000 NIC must be used.

## Known limitations

### Only the deployment storage device is used
Custom storage configuration is not supported as VMware ESXi has specific requirements for how files are written to the disk. MAAS will extend datastore1 to the full size of the deployment disk. After deployment VMware tools may be used to access the other disks.

### IP Address not assoicated with machine
VMware ESXi connects the physical NIC to a vSphere Standard Switch and creates a new VMkernel adapter for networking. The VMkernel adapter has its own MAC address which is recognized by MAAS as a new device. Custom network configuration is not supported.

### Image fails to build due to qemu-nbd error
If the image fails to build due to a qemu-nbd error try disconnecting the device with
```
$ sudo qemu-nbd -d /dev/nbd4
```
