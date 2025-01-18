# SLES 15 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a SLES 15 AMD64/ARM64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [SLES 15 DVD ISO](https://www.suse.com/download/sles/)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.4+
* [Curtin](https://launchpad.net/curtin) 23.1+

## Customizing the Image

The deployment image may be customized by modifying `http/sles15.xml.pkrtpl.hcl`. See the [AutoYaST documentation](https://documentation.suse.com/sles/15/html/SLES-all/book-autoyast.html) for more information.

## Building the image using a proxy

The Packer template pulls all packages from the DVD ISO. To use a proxy during the installation you need to check the [AutoYaST documentation](https://documentation.suse.com/sles/15/html/SLES-all/book-autoyast.html).

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/SLE-15-SP6-Full-x86_64-GM-Media1.iso ARCH=x86_64
```

To build arm64 images:

```shell
make ISO=/PATH/TO/SLE-15-SP6-Full-aarch64-GM-Media1.iso ARCH=aarch64
```

Note: `sles.pkr.hcl` is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of `headless` to false in
`sles.pkr.hcl`.

Installation is non-interactive.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

### ISO

The path to the installation ISO image for SLES.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='suse/sles15' title='SLES 15' \
    architecture='amd64/generic' filetype='tgz' \
    content@=sles15.tar.gz
```

## Default Username

The default username is ```sles```
