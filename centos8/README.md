# CentOS 8 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a CentOS 8 AMD64 image for use
with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+, [MAAS](https://maas.io) 2.7+ recommended
* [Curtin](https://launchpad.net/curtin) 19.3-792+

## Default user

The default username is cloud-user

## Customizing the Image

The deployment image may be customized by modifying http/centos8.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy

The Packer template downloads the CentOS net installer from the Internet. To
tell Packer to use a proxy set the HTTP_PROXY environment variable to your proxy
server. Alternatively you may redefine iso_url to a local file, set
iso_checksum_type to none to disable checksuming, and remove iso_checksum_url.

To use a proxy during the installation define the `KS_PROXY` variable in the
environment, as bellow:

```shell
export KS_PROXY=$HTTP_PROXY
```

## Building an image

You can easily build the image using the Makefile:

```shell
make
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/centos8, where this file is located. Once in
packer-maas/centos8 you can generate an image with:

```shell
packer init
PACKER_LOG=1 packer build .
```

Note: centos8.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
centos8.pkr.hcl.

Installation is non-interactive.

### Makefile Parameters

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='centos/8-custom' title='CentOS 8 Custom' \
    architecture='amd64/generic' filetype='tgz' \
    base_image='centos/8' content@=centos8.tar.gz
```

## Default Username

The default username is ```cloud-user```
