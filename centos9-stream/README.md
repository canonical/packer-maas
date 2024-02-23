# CentOS 9 Stream Packer Template for MAAS

## Introduction

The Packer template in this directory creates a CentOS 9 Stream AMD64 image for use
with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04 with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.0, [MAAS](https://maas.io) 3.2 recommended
* [Curtin](https://launchpad.net/curtin) 21+

## Default user

The default username is cloud-user

## Customizing the Image

The deployment image may be customized by modifying http/centos9-stream.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy

The Packer template downloads the CentOS net installer from the Internet. To
tell Packer to use a proxy set the HTTP_PROXY environment variable to your proxy
server. Alternatively you may redefine iso_url to a local file.

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
be in packer-maas/centos9-stream, where this file is located. Once in
packer-maas/centos9-stream you can generate an image with:

```shell
packer init
PACKER_LOG=1 packer build .
```

Note: centos9-stream.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
centos9-stream.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='custom/9-stream-custom' title='CentOS 9 Stream Custom' \
    architecture='amd64/generic' filetype='tgz' base_image='rhel/9' \
    content@=centos9-stream.tar.gz
```

## Default Username

The default username is ```cloud-user```
