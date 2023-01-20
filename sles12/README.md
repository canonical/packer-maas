# SLES 12 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a SLES 12 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils
* cloud-image-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [SLES JeOS 12-SP5 OpenStack/Cloud image](https://www.suse.com/download/sles/)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized using `cloud-init` configuration. Check the `user-data` file.

## Building the image using a proxy

The Packer template pulls all packages from the upstream image. To use a proxy during the installation add the `--proxy=$HTTP_PROXY` flag to every line starting with url or repo in `http/sles.xml`.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2
```

Alternatively you can manually run packer. Your current working directory must be in `packer-maas/sles12`, where this file is located. Once in `packer-maas/sles12` you can generate an image with:

```shell
sudo packer init
sudo PACKER_LOG=1 packer build -var 'sles_iso_path=/PATH/TO/SLES12-SP5-JeOS.x86_64-12.5-OpenStack-Cloud-GM.qcow2' .
```

Note: `sles.pkr.hcl` is configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the packer output or change the value of `headless` to false in `sles.pkr.hcl`.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='suse/sles12.5' title='SLES 12-SP5' \
    architecture='amd64/generic' filetype='tgz' \
    content@=sles12.tar.gz
```

## Default Username

The default username is ```sles```
