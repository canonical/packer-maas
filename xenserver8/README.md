# XenServer 8 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a XenServer 8 AMD64 image for use with MAAS.

This template is also compatible with [XCP-ng](https://xcp-ng.org/) which is the Open Source equivalent.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.11.0 or newer
* The [XenServer 8 ISO](https://www.xenserver.com/downloads)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying the http/xenserver8.xml.pkrtpl.hcl answer file. 
See the [XenServer Answer file reference](https://docs.xenserver.com/en-us/xenserver/8/install/advanced-install#create-an-answer-file-for-unattended-installation) for more information.

For XCP-ng, see the [Answer file page](https://docs.xcp-ng.org/appendix/answerfile/).

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/XenServer8_2024-12-09.iso
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/xenserver8, where this file is located. Once in packer-maas/xenserver8
you can generate an image with:

```shell
packer init
PACKER_LOG=1 packer build -var 'xenserver8_iso_path=/PATH/TO/XenServer8_2024-12-09.iso'.
```

The installation process non-interactive. Note this image only supports UEFI boot mode.

## Network Device Name Compatibility Note

Both XenServer and XCP-ng ship with a custom Linux kernel 4.19 which uses the traditional
NIC naming schema. This requires commissioning and deployment using the following 
kernel paramaters on target machines on MAAS:

```
net.ifnames=0 biosdevname=0
```

For additional hardware support details, refer to the [HCL Page](https://hcl.xenserver.com/).

### Makefile Parameters

#### HEADLESS

Defaults to true. Set to false in order to see the VM during the build process.

### ISO

The path to the installation ISO image for XenSever or XCP-ng.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='custom/xenserver8' title='XenServer 8' \
    architecture='amd64/generic' filetype='ddgz' \
    base_image='rhel/8' content@=xenserver8-lvm.dd.gz
```

## Default Username

The default username is ```centos```.
