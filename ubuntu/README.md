# Ubuntu Packer Template for MAAS

## Introduction

The Packer template in this directory creates a Ubuntu AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* ovmf
* cloud-image-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.0+
* [Curtin](https://launchpad.net/curtin) 21.0+

## Customizing the Image

It is possible to customize the image either during the Ubuntu installation or afterwards, before packing the final image. The former is done by providing [autoinstall config](https://ubuntu.com/server/docs/install/autoinstall), editing the _user-data-flat_ and _user-data-lvm_ files. The latter is performed by the _install-custom-packages_ script.

## Building the image using a proxy

The Packer template downloads the Ubuntu net installer from the Internet. To tell Packer to use a proxy set the HTTP_PROXY environment variable to your proxy server. Alternatively you may redefine iso_url to a local file, set iso_checksum_type to none to disable checksuming, and remove iso_checksum_url.

## Building an image

You can easily build the image using the Makefile:

```shell
$ make custom-ubuntu-lvm.dd.gz
```

to build a raw image with LVM, alternatively, you can build a TGZ image

```shell
$ make custom-ubuntu.tar.gz
```

You can also manually run packer. Your current working directory must
be in packer-maas/ubuntu, where this file is located. Once in
packer-maas/ubuntu you can generate an image with:

```shell
$ sudo PACKER_LOG=1 packer build ubuntu-lvm.json
# or
$ sudo PACKER_LOG=1 packer build ubuntu-flat.json
```

Note: ubuntu-lvm.json and ubuntu-flat.json are configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or change the value of headless to false in the JSON file.

Installation is non-interactive.

## Uploading images to MAAS

LVM raw image

```shell
$ maas admin boot-resources create \
    name='custom/ubuntu-raw' \
    title='Ubuntu Custom RAW' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=custom-ubuntu-lvm.dd.gz
```

TGZ image

```shell
$ maas admin boot-resources create \
    name='custom/ubuntu-tgz' \
    title='Ubuntu Custom TGZ' \
    architecture='amd64/generic' \
    filetype='tgz' \
    content@=custom-ubuntu.tar.gz
```

## Default Username

The default username is ```ubuntu```
