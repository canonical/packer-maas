# Proxmox Virtual Environment (PVE) Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates pve image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* qemu-system
* ovmf
* cloud-image-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.2+
* [Curtin](https://launchpad.net/curtin) 21.0+
* Create inside of MAAS a vmbr0 bridge with your interfaces. 

## Supported Proxmox Versions

The builds and deployment has been tested on MAAS 3.5.4 with Noble ephemeral images,
in UEFI mode. The process currently works with the following PVE versions:

* Proxmox Virtual Environment 8.4-1

## Supported Architectures

Currently amd64 (x86_64) architecture is supported.

## Known Issues

* After the deployment process PXE Boot directly into PVE is not working
* Proxmox Services will not start because in /etc/hosts there is 127.0.0.1 configured for the hostname/fqdn. Please change the 127.0.0.1 to the correct ip address

## pve.pkr.hcl

This template builds a dd.gz image from the official Proxmox iso.

### Building the image

The build the image you give the template a script which has all the
customizations:

```shell
packer init .
packer build .
```

Using make:

```shell
make pve
```

### Custom Preseed for Proxmox

As mentioned above, pve images require a custom preseed file to be present in the
preseeds directory of MAAS region controllers. 

When used snaps, the path is /var/snap/maas/current/preseeds/curtin_userdata_custom

Example ready to use preesed files has been included with this repository. Please
see curtin_userdata_custom_amd64.

**Please be aware** this could potentially create a conflict with the rest of custom
images present in your setup. To work around a conflict, it is possible to rename the
preseed file something similar to curtin_userdata_custom_amd64_generic_pve-8-4-1 assuming
the architecture was set to amd64/generic and the uploaded **name** was set to custom/pve-8-4-1.

In other words, depending on the image name parameter used during the import, the preseed
file(s) can be renamed to apply in a targetted manner.

For more information about the preseed file naming schema, see
[Custom node setup (Preseed)](https://github.com/CanonicalLtd/maas-docs/blob/master/en/nodes-custom.md) and
[Preseed filenames](https://github.com/canonical/maas/blob/master/src/maasserver/preseed.py#L756).

### Makefile Parameters

#### PACKER_LOG

Enable (1) or Disable (0) verbose packer logs. The default value is set to 0.

## Uploading images to MAAS

DD.GZ

```shell
maas $PROFILE boot-resources create \
    name='custom/pve-8-4-1' \
    title='Proxmox VE 8.4-1' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=pve_lvm.dd.gz
```