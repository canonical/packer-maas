# Debian Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates Debian images for use with MAAS.

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
* [A Custom Preseed for Debian (Important - See below)]

## Supported Debian Versions

The builds and deployment has been tested on MAAS 3.3.5 with Jammy ephemeral images,
in BIOS and UEFI modes. The process currently works with the following Debian series:

* Debian 10 (Buster)
* Debian 11 (Bullseye)
* Debian 12 (Bookworm)

## Supported Architectures

Currently amd64 (x86_64) and arm64 (aarch64) architectures are supported with aemd64
being the default.

## Known Issues

* UEFI images fro Debian 10 (Buster) and 11 (Bullseye) are usable on both BIOS and 
UEFI systems. However for Debian 12 (Bookworm) explicit images are required to
support BIOS and UEFI modes. See BOOT make parameter for more details.


## debian-cloudimg.pkr.hcl

This template builds a tgz image from the official Debian cloud images. This
results in an image that is very close to the ones that are on
<https://images.maas.io/>.

### Building the image

The build the image you give the template a script which has all the
customizations:

```shell
packer init .
packer build -var customize_script=my-changes.sh -var debian_series=bullseye \
    -var debian_version=11 .
```

`my-changes.sh` is a script you write which customizes the image from within
the VM. For example, you can install packages using `apt-get`, call out to
ansible, or whatever you want.

Using make:

```shell
make debian SERIES=bullseye
```

#### Accessing external files from you script

If you want to put or use some files in the image, you can put those in the `http` directory.

Whatever file you put there, you can access from within your script like this:

```shell
wget http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}:/my-file
```

### Installing a kernel

If you do want to force an image to always use a specific kernel, you can
include it in the image.

The easiest way of doing this is to use the `kernel` parameter:

```shell
packer init .
packer build -var kernel=linux-image-amd64 -var customize_script=my-changes.sh .
```

You can also install the kernel manually in your `my-changes.sh` script.

### Custom Preseed for Debian

As mentioned above, Debian images require a custom preseed file to be present in the
preseeds directory of MAAS region controllers. 

When used snaps, the path is /var/snap/maas/current/preseeds/curtin_userdata_custom

Example ready to use preesed files has been included with this repository. Please
see curtin_userdata_custom_amd64 and curtin_userdata_custom_arm64.

Please be aware that this could potentially create a conflict with the rest of custom
images present in your setup, hence a through investigation and testing might be
required prior to deployment.

To work around a conflict, it is possible to name the preseed file something similar to
curtin_userdata_custom_amd64_generic_debian-10 assuming the architecture was set to
amd64/generic and the uploaded name was set to custom/debian-10.

### Makefile Parameters

#### PACKER_LOG

Enable (1) or Disable (0) verbose packer logs. The default value is set to 0.

#### SERIES

Specify the Debian Series to build. The default value is set to bullseye.

#### BOOT

Supported boot mode baked into the image. The default is set to uefi. Please
see the Known Issues section for more details. This parameter is only valid 
for amd64 architecture.

#### ARCH

Target image architecture. Supported values are amd64 (default) and arm64.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

### Default Username

The default username is ```debian```

## Uploading images to MAAS

TGZ image

```shell
maas admin boot-resources create \
    name='custom/debian-12' \
    title='Debian 12 Custom' \
    architecture='amd64/generic' \
    filetype='tgz' \
    content@=debian-custom-cloudimg.tar.gz
```
