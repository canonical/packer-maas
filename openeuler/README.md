# OpenEuler Packer Template for MAAS

## Introduction

The Packer template in this directory creates a OpenEuler AMD64/ARM64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [OpenEuler DVD ISO](https://www.openeuler.org/en/download/?archive=true)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying http/openeuler.ks.pkrtpl.hcl. See the [OpenEuler kickstart documentation](https://docs.openeuler.org/en/docs/20.09/docs/Installation/using-kickstart-for-automatic-installation.html) for more information.

## Building the image using a proxy

The Packer template pulls all packages from the DVD. To use a proxy during the installation define the
`KS_PROXY` variable in the environment, as bellow:

```shell
export KS_PROXY=$HTTP_PROXY
```

## Building an image

You can easily build the image using the Makefile:

```shell
make ISO=/PATH/TO/openEuler-24.03-LTS-SP3-x86_64-dvd.iso
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/openeuler, where this file is located. Once in packer-maas/openeuler
you can generate an image with:

```shell
packer init
PACKER_LOG=1 packer build -var 'openeuler_iso_path=/PATH/TO/openEuler-24.03-LTS-SP3-x86_64-dvd.iso' .
```

Note: openeuler.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
openeuler.pkr.hcl.

Installation is non-interactive.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

### ISO

The path to the installation ISO image for OpenEuler.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='rhel/10' title='OpenEuler Custom' \
    architecture='amd64/generic' filetype='tgz' \
    content@=openeuler.tar.gz
```

For ARM64, use:

```shell
maas $PROFILE boot-resources create \
    name='rhel/10' title='OpenEuler Custom' \
    architecture='arm64/generic' filetype='tgz' \
    content@=openeuler.tar.gz
```

Please note that, currently due to lack of support in curtin, deploying ARM64 images needs a preseed file. This is due to [LP# 2090874](https://bugs.launchpad.net/curtin/+bug/2090874) and currently is in the process of getting fixed.

```
#cloud-config
debconf_selections:
 maas: |
  {{for line in str(curtin_preseed).splitlines()}}
  {{line}}
  {{endfor}}
  
extract_commands:
  grub_install: curtin in-target -- cp -v /boot/efi/EFI/openEuler/shimaa64.efi /boot/efi/EFI/openEuler/shimx64.efi

late_commands:
  maas: [wget, '--no-proxy', '{{node_disable_pxe_url}}', '--post-data', '{{node_disable_pxe_data}}', '-O', '/dev/null']
  bootloader_01: ["curtin", "in-target", "--", "cp", "-v", "/boot/efi/EFI/openEuler/shimaa64.efi", "/boot/efi/EFI/BOOT/bootaa64.efi"]
  bootloader_02: ["curtin", "in-target", "--", "cp", "-v", "/boot/efi/EFI/openEuler/grubaa64.efi", "/boot/efi/EFI/BOOT/"]
```

This file needs to be saved on Region Controllers under /var/snap/maas/current/preseeds/curtin_userdata_custom_arm64_generic_openeuler or /etc/maas/preseeds/curtin_userdata_custom_arm64_generic_openeuler. The last portion of this file must match the image name uploaded in MAAS.

## Default Username

The default username is ```openeuler```
