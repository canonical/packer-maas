# Ubuntu Packer Template for MAAS

## Introduction
The Packer template in this directory creates a Ubuntu AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* cloud-image-utils
* [Packer.](https://www.packer.io/intro/getting-started/install.html)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+
* [Curtin](https://launchpad.net/curtin) 18.1-59+

## Customizing the Image

TODO

## Building the image using a proxy
The Packer template downloads the Ubuntu
net installer from the Internet. To tell Packer to use a proxy set the
HTTP_PROXY environment variable to your proxy server. Alternatively you may
redefine iso_url to a local file, set iso_checksum_type to none to disable
checksuming, and remove iso_checksum_url.

## Building an image
You can easily build the image using the Makefile:

```
$ make
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/ubuntu, where this file is located. Once in
packer-maas/ubuntu you can generate an image with:

```
$ sudo PACKER_LOG=1 packer build ubuntu.json
```

Note: ubuntu.json is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
ubuntu.json.

Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas admin boot-resources create \
    name='ubuntu/asouza' \
    title='Ubuntu Custom' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=custom-ubuntu.dd.gz
```

## Default Username
The default username is ```ubuntu```
