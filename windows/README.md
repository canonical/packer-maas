# Packer Template for Microsoft Windows

## Introduction

The Packer templates in this directory creates Windows Server images for use with MAAS.


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


## Supported Microsoft Windows Versions

This process has been build and deployment tested with the following versions of
Microsoft Windows:

* Windows Server 2022
* Windows Server 2019
* Windows Server 2016
* Windows 10 Pro 22H2


## Known Issues

* The current process builds UEFI compatible images only.


## windows.json Template

This template builds a dd.tgz MAAS image from an official Microsoft Windows ISO. 
This process also installs the latest VirtIO drivers as well as Cloudbase-init.


## Obtaining Microsoft Windows ISO images

You can obtains Microsoft Windows Evaluation ISO images from the following links:

* [Windows Server 2022](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)
* [Windows Server 2019](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2019)
* [Windows Server 2016](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016)


### Building the image

The build the image you give the template a script which has all the
customization:

```shell
sudo make windows ISO=<path-to-iso> VERSION=<windows-version> windows.json
```

### Makefile Parameters

#### BOOT

Currently uefi is the only supported value.

#### EDIT

The edition of a targeted ISO image. It defaults to PRO for Microsoft Windows 10/11
and SERVERSTANDARD for Microsoft Windows Servers. Many Microsoft Windows Server ISO
images do contain multiple editions and this prarameter is useful to build a particular
edition such as Standard or Datacenter etc.

#### HEADLESS

Whether VNC viewer should not be launched. Default is set to false.

#### ISO

Path to Microsoft Windows ISO used to build the image.

#### PACKER_LOG

Enable (1) or Disable (0) verbose packer logs. The default value is set to 0.

#### PKEY

User supplied Microsoft Windows Product Key. When usimg KMS, you can obtain the
activation keys from the link below:

* [KMS Client Activation and Product Keys](https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys)

Please note that PKEY is an optional parameter but it might be required during
the build time depending on the type of ISO being used. Evaluation series ISO
images usually do not require a product key to proceed, however this is not
true with Enterprise and Retail ISO images.

#### VERSION

Specify the Microsoft Windows Version. Example inputs include: 2022, 2019, 2016
and 10.


## Uploading images to MAAS

Use MAAS CLI to upload the image:

```shell
maas admin boot-resources create \
    name='windows/windows-server' \
    title='Windows Server' \
    architecture='amd64/generic' \
    filetype='ddtgz' \
    content@=windows-server-amd64-root-dd.gz
```
