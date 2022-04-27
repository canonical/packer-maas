# RHEL 7 Packer Template for MAAS

## Introduction
The Packer template in this directory creates a RHEL 7 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html)
* The [RHEL 7 DVD ISO](https://developers.redhat.com/products/rhel/download)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+
* [Curtin](https://launchpad.net/curtin) 18.1-59+

## Customizing the Image
The deployment image may be customized by modifying http/rhel7.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy
The Packer template pulls all packages from the DVD except for Canonical's
cloud-init repository. To use a proxy during the installation add the
--proxy=$HTTP_PROXY flag to every line starting with url or repo in
http/rhel7.ks. Alternatively you may set the --mirrorlist values to a
local mirror.

## Building an image
You can easily build the image using the Makefile:

```
$ make ISO=/PATH/TO/rhel-server-7.9-x86_64-dvd.iso
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/rhel7, where this file is located. Once in packer-maas/rhel7
you can generate an image with:

```
$ sudo PACKER_LOG=1 packer build -var 'rhel7_iso_path=/PATH/TO/rhel-server-7.9-x86_64-dvd.iso' rhel7.json
```

Note: rhel7.json is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
rhel7.json.

Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create
name='rhel/7-custom' title='RHEL 7 Custom' architecture='amd64/generic' filetype='tgz' content@=rhel7.tar.gz
```

## Default Username
The default username is ```cloud-user```
