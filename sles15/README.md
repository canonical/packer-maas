# SLES 15 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a SLES 15 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [SLES 15-SP4 DVD ISO](https://www.suse.com/download/sles/)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying `http/sles15.xml`. See the [AutoYaST documentation](https://documentation.suse.com/sles/15-SP4/html/SLES-all/book-autoyast.html) for more information.

## Building the image using a proxy

The Packer template pulls all packages from the DVD ISO. To use a proxy during the installation you need to check the [AutoYaST documentation](https://documentation.suse.com/sles/15-SP4/html/SLES-all/book-autoyast.html).

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/SLE-15-SP4-Full-x86_64-GM-Media1.iso
```

Alternatively you can manually run packer. Your current working directory must
be in `packer-maas/sles15`, where this file is located. Once in packer-maas/sles15
you can generate an image with:

```shell
sudo packer init
sudo PACKER_LOG=1 packer build -var 'sles15_iso_path=/PATH/TO/SLE-15-SP4-Full-x86_64-GM-Media1.iso' .
```

Note: `sles.pkr.hcl` is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of `headless` to false in
`sles.pkr.hcl`.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='suse/sles15.4' title='SLES 15-SP4' \
    architecture='amd64/generic' filetype='tgz' \
    content@=sles15.tar.gz
```

## Default Username

The default username is ```sles```
