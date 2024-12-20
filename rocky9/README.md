# Rocky 9 Packer template for MAAS

## Introduction

The Packer template in this directory creates a Rocky 9 AMD64/ARM64 image for use with MAAS.

## Prerequisites to create the image

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* qemu-system
* qemu-system-modules-spice (If building on Ubuntu 24.04 LTS "Noble")
* ovmf
* cloud-image-utils
* parted
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.11.0 or newer

## Requirements to deploy the image

* [MAAS](https://maas.io) 3.3 or later, as that version introduces support for Rocky
* [Curtin](https://launchpad.net/curtin) 22.1. If you have a MAAS with an earlier Curtin version, you can [patch](https://code.launchpad.net/~xnox/curtin/+git/curtin/+merge/415604) distro.py to deploy Rocky.

## Customizing the image

You can customize the deployment image by modifying http/rocky.ks. See the [RHEL kickstart documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/performing_an_advanced_rhel_installation/kickstart-commands-and-options-reference_installing-rhel-as-an-experienced-user#part-or-partition_kickstart-commands-for-handling-storage) for more information.

## Building the image using a proxy

The Packer template downloads the Rocky ISO image from the Internet. You can tell Packer to use a proxy by setting the HTTP_PROXY environment variable to point to your proxy server. You can also redefine rocky_iso_url to a local file. If you want to skip the base image integrity check, set iso_checksum_type to none and remove iso_checksum.

To use a proxy during the installation define the `KS_PROXY` variable in the environment, as bellow:

```shell
export KS_PROXY="\"${HTTP_PROXY}\""
```

# Building the image using a kickstart mirror

To tell Packer to use a specific mirror set the `KS_MIRROR` environment variable
poiniting to the mirror URL.

```shell
export KS_MIRROR="https://dl.rockylinux.org/pub/rocky/9"
```

## Building an image

You can build the image using the Makefile:

```shell
make
```

You can also manually run packer. Set your current working directory to packer-maas/rocky9, where this file resides, and generate an image with:

```shell
packer init
PACKER_LOG=1 packer build .
```

The installation runs in a non-interactive mode.

Note: rocky9.pkr.hcl runs Packer in headless mode, with the serial port output from qemu redirected to stdio to give feedback on image creation process. If you wish to see more, change the value of `headless` to `false` in rocky9.pkr.hcl, remove `[ "-serial", "stdio" ]` from `qemuargs` section and select `View`, then `serial0` in the qemu window that appears during build. This lets you watch progress of the image build script. Press `ctrl-b 2` to switch to shell to explore more, and `ctrl-b 1` to go back to log view.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create name='custom/rocky9' \
    title='Rocky 9 Custom' architecture='amd64/generic' \
    base_image='rhel/9' filetype='tgz' \
    content@=rocky9.tar.gz
```

For ARM64, use:

```shell
maas $PROFILE boot-resources create name='custom/rocky9' \
    title='Rocky 9 Custom' architecture='arm64/generic' \
    base_image='rhel/9' filetype='tgz' \
    content@=rocky9.tar.gz
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
  grub_install: curtin in-target -- cp -v /boot/efi/EFI/rocky/shimaa64.efi /boot/efi/EFI/rocky/shimx64.efi

late_commands:
  maas: [wget, '--no-proxy', '{{node_disable_pxe_url}}', '--post-data', '{{node_disable_pxe_data}}', '-O', '/dev/null']
  bootloader_01: ["curtin", "in-target", "--", "cp", "-v", "/boot/efi/EFI/rocky/shimaa64.efi", "/boot/efi/EFI/BOOT/bootaa64.efi"]
  bootloader_02: ["curtin", "in-target", "--", "cp", "-v", "/boot/efi/EFI/rocky/grubaa64.efi", "/boot/efi/EFI/BOOT/"]
```

This file needs to be saved on Region Controllers under /var/snap/maas/current/preseeds/curtin_userdata_custom_arm64_generic_rocky9 or /etc/maas/preseeds/curtin_userdata_custom_arm64_generic_rocky9. The last portion of this file must match the image name uploaded in MAAS.

## Default username

MAAS uses cloud-init to create ```cloud-user``` account using the ssh keys configured for the MAAS admin user (e.g. imported from Launchpad). Log in to the machine:

```shell
ssh -i ~/.ssh/<your_identity_file> cloud-user@<machine-ip-address>
```

Next to that, the kickstart script creates an account with both username and password set to  ```rocky```. Note that the default sshd configuration in Rocky 9 disallows password-based authentication when logging in via ssh, so trying `ssh rocky@<machine-ip-address>` will fail. Password-based authentication can be enabled by having `PasswordAuthentication yes` in /etc/ssh/sshd_config after logging in with ```cloud-user```. Perhaps there is a way to make that change using kickstart script, but it is not obvious as ```anaconda```, the installer, makes its own changes to sshd_config file during installation. If you know how to do this, a PR is welcome.
