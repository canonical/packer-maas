# SLES 16 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a SLES 16 AMD64/ARM64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [SLES 16 DVD ISO](https://www.suse.com/download/sles/)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 23.1+

## Customizing the Image

The deployment image may be customized by modifying `profile.json.pkrtpl.hcl`.

See the [Agama installer](https://github.com/agama-project/agama/tree/master) for more information.

## Autoinstall Debugging

Important Note: SLES 16 is using [Agama installer](https://github.com/agama-project/agama/tree/master) which replaces YaST.

This installer does support AutoYaST autoinstall profiles up to some extent. 
This means an existing profile may need changes and modifications to fully
work.

The new installer is Web based and currently does not prompt or show any
error messages related to a failed autoinstaller profile.

The failure symptom is that the installer is stuck and not making progress.

To investigate, connect to the console using a VNC viewer or similar, issue
Ctrl+Alt+F1 and login as root (password shown on console). Then investigate 
using:

```shell
journalctl -u agama-auto
```
## Known Issues

* As of December 2025, with SLES16.0 ISO, the cloud-init package is missing
from the installation DVD. Until this is resolved, we have a workaround to
download and install the package from OpenSUSE online repositories.

## Building the image using a proxy

The Packer template pulls all packages from the DVD ISO. 

To use a proxy during the installation you need to check the [Agama installer](https://github.com/agama-project/agama/tree/master) for more information.

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/SLE-16-Full-x86_64-GM-Media1.iso ARCH=x86_64
```

To build arm64 images:

```shell
make ISO=/PATH/TO/SLE-16-Full-aarch64-GM-Media1.iso ARCH=aarch64
```

Note: `sles.pkr.hcl` is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of `headless` to false in
`sles.pkr.hcl`.

Installation is non-interactive.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

### ISO

The path to the DVD installation ISO image for SLES.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='suse/sles16' title='SLES 16' \
    architecture='amd64/generic' filetype='tgz' \
    content@=sles16.tar.gz
```

## Default Username

The default username is ```sles```
