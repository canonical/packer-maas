# Azure Linux (CBL-Mariner) Packer template for MAAS

## Introduction

The Packer template in this directory creates a [Azure Linux](https://github.com/microsoft/azurelinux) AMD64 image for use with MAAS.
This distribution was formerly known as `CBL-Mariner`.

## Prerequisites to create the image

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements to deploy the image

* [MAAS](https://maas.io) 3.3 or later
* [Curtin](https://launchpad.net/curtin) 22.1 or later

## Customizing the image

See curtin/install-custom-packages file.

## Building the image

The Packer template needs the [AzureLinux-3.0 ISO image](https://aka.ms/AzureLinux-3.0-x86_64.iso).

Currently both 2.0 and 3.0 ISO images are supported.

You can build the image using the Makefile:

```shell
make azurelinux.tar.gz ISO=/path/to/AzureLinux-3.0-x86_64.iso
```

The installation runs in a non-interactive mode.

Note: mariner-packer.pkr.hcl runs Packer in headless mode, with the serial port output from qemu redirected to stdio to give feedback on image creation process. If you wish to see more, change the value of `headless` to `false` in mariner-packer.pkr.hcl, and remove `[ "-serial", "stdio" ]` from `qemuargs` section. This lets you watch progress of the image build script. Press `ctrl-b 2` to switch to shell to explore more, and `ctrl-b 1` to go back to log view.

### Makefile Parameters

#### PACKER_LOG

Setting this to `PACKER_LOG=1` will show verbose output during the build process.

#### ISO

The path to the ISO image.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create name='custom/azure-linux-3.0' \
    title='Azure Linux 3.0 Custom' architecture='amd64/generic' \
    base_image='rhel/8' filetype='tgz' \
    content@=azurelinux.tar.gz
```

## Default username

MAAS uses cloud-init to create ```mariner``` (for 2.0) or ```azurelinux``` (for 3.0) accounts using the ssh keys configured for the MAAS admin user (e.g. imported from Launchpad). Log in to the machine:

```shell
ssh -i ~/.ssh/<your_identity_file> azurelinux@<machine-ip-address>
```

The autoinstall script sets the `mariner` account password to `mariner`.
