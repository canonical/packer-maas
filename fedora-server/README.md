# Fedora Server Packer Template for MAAS

## Introduction

The Packer template in this directory creates a Fedora Server AMD64/ARM64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [Fedora Server DVD ISO](https://fedoraproject.org/server/download)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying http/fedora-server.ks.pkrtpl.hcl. See the [Fedora kickstart documentation](https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/advanced/Kickstart_Installations/) for more information.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/Fedora-Server-dvd-x86_64-42-1.1.iso
```

Note: fedora-server.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
fedora-server.pkr.hcl.

Installation is non-interactive.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

#### ISO

The path to the installation ISO image for Fedora Server.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

#### VERSION

Fedora Server version. Default is currently set to 42. 

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='custom/fedora-server' title='Fedora Server Custom' \
    architecture='amd64/generic' filetype='tgz' \
    base_image='rhel/9' content@=fedora-server.tar.gz
```

For ARM64, use:

```shell
maas $PROFILE boot-resources create \
    name='custom/fedora-server' title='Fedora Server Custom' \
    architecture='arm64/generic' filetype='tgz' \
    base_image='rhel/9' content@=fedora-server.tar.gz
```

This file needs to be saved on Region Controllers under /var/snap/maas/current/preseeds/curtin_userdata_rhel_arm64_generic_fedora-server or /etc/maas/preseeds/curtin_userdata_rhel_arm64_generic_fedora-server. The last portion of this file must match the image name uploaded in MAAS.

## Default Username

The default username is ```fedora```
