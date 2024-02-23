# OL 9 Packer Template for MAAS

## Introduction

The Packer template in this directory creates an OL 9 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.5+
* [Curtin](https://launchpad.net/curtin) 23.1+

## Customizing the Image

The deployment image may be customized by modifying http/ol9.ks. See the [OL9 kickstart documentation](https://docs.oracle.com/en/operating-systems/oracle-linux/9/install/install-AutomatinganOracleLinuxInstallationbyUsingKickstart.html) for more information.

## Building the image using a proxy

The Packer template downloads the OL net installer from the Internet. To
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
be in packer-maas/ol9, where this file is located. Once in packer-maas/ol9
you can generate an image with:

```shell
packer init .
PACKER_LOG=1 packer build .
```

Note: ol9.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
ol9.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='ol/9.2' title='Oracle Linux 9.2' \
    architecture='amd64/generic' filetype='tgz' \
    content@=ol9.tar.gz
```

## Default Username

The default username is ```cloud-user```
