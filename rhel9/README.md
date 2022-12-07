# RHEL 9 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a RHEL 9 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [RHEL 9 DVD ISO](https://developers.redhat.com/products/rhel/download)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying http/rhel9.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy

The Packer template pulls all packages from the DVD except for Canonical's
cloud-init repository. To use a proxy during the installation add the
--proxy=$HTTP_PROXY flag to every line starting with url or repo in
http/rhel9.ks. Alternatively you may set the --mirrorlist values to a
local mirror.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/rhel-baseos-9.1-x86_64-dvd.iso
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/rhel9, where this file is located. Once in packer-maas/rhel9
you can generate an image with:

```shell
sudo packer init
sudo PACKER_LOG=1 packer build -var 'rhel9_iso_path=/PATH/TO/rhel-baseos-9.1-x86_64-dvd.iso' .
```

Note: rhel9.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
rhel9.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='rhel/9-custom' title='RHEL 9 Custom' \
    architecture='amd64/generic' filetype='tgz' \
    content@=rhel9.tar.gz
```

## Default Username

The default username is ```cloud-user```
