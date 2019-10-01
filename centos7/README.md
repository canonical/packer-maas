# CentOS 7 Packer Template for MAAS

## Introduction
The Packer template in this directory creates a CentOS 7 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+
* [Packer.](https://www.packer.io/intro/getting-started/install.html)

## Customizing the Image
The deployment image may be customized by modifying packer-maas/centos7/http/centos7.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy
The Packer template downloads the CentOS net installer from the Internet. To tell Packer to use a proxy set the HTTP_PROXY environment variable to your proxy server. Alternatively you may redefine iso_url to a local file, set iso_checksum_type to none to disable checksuming, and remove iso_checksum_url.

To use a proxy when installing add "inst.proxy=$HTTP_PROXY" to the boot_command in centos7.json. Alternatively you may change inst.repo and the repo lines in centos7.ks to a local mirror.

## Building an image
Your current working directory must be in packer-maas/centos7, where this file is located. Once in packer-maas/centos7 you can generate an image with:
```
$ sudo packer build centos7.json
```

Note: centos7.json is configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or remove the line containing "headless" in centos7.json.

Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create name='centos/7-custom' title='CentOS 7 Custom' architecture='amd64/generic' filetype='tgz' content@=centos7.tar.gz
```
