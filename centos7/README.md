# CentOS 7 Packer Template for MAAS

## Introduction
The Packer template in this directory creates a CentOS 7 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* [Packer.](https://www.packer.io/intro/getting-started/install.html)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+
* [Curtin](https://launchpad.net/curtin) 18.1-59+

## Customizing the Image
The deployment image may be customized by modifying http/centos7.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Dell RAID Support
Support for older Dell RAID cards can be added by downloading the appropriate driver from [Dell's website](https://www.dell.com/support/search/en-us#q=Red%20Hat%20Enterprise%20Linux%207%20Driver%20for%20Dell%20PERC%20version&sort=relevancy&numberOfResults=100&f:langFacet=[en])

* Un-archive the tar.gz file
* Unzip the iso file
* Place the iso file into the ~/http directory
* Then modify the ~/centos7.json file as such:

```
                "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos7.ks ",
+                "inst.dd=http://{{ .HTTPIP }}:{{ .HTTPPort }}/megaraid_sas-$VERSION.x86_64.iso ",
                "console=ttyS0 inst.cmdline",
```

## Building the image using a proxy
The Packer template downloads the CentOS
net installer from the Internet. To tell Packer to use a proxy set the
HTTP_PROXY environment variable to your proxy server. Alternatively you may
redefine iso_url to a local file, set iso_checksum_type to none to disable
checksuming, and remove iso_checksum_url.

To use a proxy during the installation add the --proxy=$HTTP_PROXY flag to every
line starting with url or repo in http/centos7.ks. Alternatively you may set the
--mirrorlist values to a local mirror.

## Building an image
Your current working directory must be in packer-maas/centos7, where this file
is located. Once in packer-maas/centos7 you can generate an image with:

```
$ sudo PACKER_LOG=1 packer build centos7.json
```

Note: centos7.json is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
centos7.json.

Installation is non-interactive.

## Uploading an image to MAAS
```
$ maas $PROFILE boot-resources create
name='centos/7-custom' title='CentOS 7 Custom' architecture='amd64/generic' filetype='tgz' content@=centos7.tar.gz
```

## Default Username
The default username is ```centos```
