# Debian Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates Debian images for use with MAAS.

## Prerequisites (to create the image)

* A machine running Debian 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* qemu-system
* ovmf
* cloud-image-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.2+
* [Curtin](https://launchpad.net/curtin) 21.0+
* [A Custom Preseed for Debian (Important - See below)]

## Supported Debian Versions
The builds and deployment has been tested on MAAS 3.3.5 with Jammy ephemeral images,
in BIOS and UEFI modes. The process currently works with the following Debian series:

* Debian 10 (Buster)
* Debian 11 (Bullseye)
* Debian 12 (Bookworm)

## Known Issues
* UEFI images fro Debian 10 (Buster) and 11 (Bullseye) are usable on both BIOS and 
UEFI systems. However for Debian 12 (Bookworm) explicit images are required to
support BIOS and UEFI modes. See BOOT make parameter for more details.


## debian-cloudimg.pkr.hcl

This template builds a tgz image from the official Debian cloud images. This
results in an image that is very close to the ones that are on
<https://images.maas.io/>.

### Building the image

The build the image you give the template a script which has all the
customizations:

```shell
packer init .
packer build -var customize_script=my-changes.sh -var debian_series=bullseye \
    -var debian_version=11 -only='cloudimg.*' .
```

`my-changes.sh` is a script you write which customizes the image from within
the VM. For example, you can install packages using `apt-get`, call out to
ansible, or whatever you want.

Using make:

```shell
make debian SERIES=bullseye
```

#### Accessing external files from you script

If you want to put or use some files in the image, you can put those in the `http` directory.

Whatever file you put there, you can access from within your script like this:

```shell
wget http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}:/my-file
```

### Installing a kernel

Usually, images used by MAAS don't include a kernel. When a machine is deployed
in MAAS, the appropriate kernel is chosen for that machine and installed on top
of the chosen image.

If you do want to force an image to always use a specific kernel, you can
include it in the image.

The easiest way of doing this is to use the `kernel` parameter:

```shell
packer init .
packer build -var kernel=linux-image-amd64 -var customize_script=my-changes.sh \
    -only='cloudimg.*' .
```

You can also install the kernel manually in your `my-changes.sh` script, but in
that case you also need to write the name of the kernel package to
`/curtin/CUSTOM_KERNEL`. This is to ensure that MAAS won't install another
kernel on deploy.

### Custom Preseed for Debian
As mentioned above, Debian images require a custom preseed file to be present in the
preseeds directory of MAAS region controllers. 

When used snaps, the path is /var/snap/maas/current/preseeds/curtin_userdata_custom

An example ready to used preesed file has been included with this repository. Please
see curtin_userdata_custom.

Please be aware that this could potentially create a conflict with the rest of custom
images present in your setup, hence a through investigation and testing might be
required prior to deployment.

### Makefile Parameters

#### PACKER_LOG
Enable (1) or Disable (0) verbose packer logs. The default value is set to 0.

#### SERIES
Specify the Debian Series to build. The default value is set to bullseye.

#### BOOT
Supported boot mode baked into the image. The default is set to uefi. Please
see the Known Issues section for more details.

### Default Username

The default username is ```debian```

## Uploading images to MAAS

TGZ image

```shell
maas admin boot-resources create \
    name='custom/debian-tgz' \
    title='Debian Custom TGZ' \
    architecture='amd64/generic' \
    filetype='tgz' \
    content@=debian-custom-cloudimg.tar.gz
```
