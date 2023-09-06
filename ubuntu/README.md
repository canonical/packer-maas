# Ubuntu Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates Ubuntu images for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* qemu-system
* ovmf
* cloud-image-utils
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.0+
* [Curtin](https://launchpad.net/curtin) 21.0+

## ubuntu-cloudimg.pkr.hcl

This template builds a tgz image from the official Ubuntu cloud images. This
results in an image that is very close to the ones that are on
<https://images.maas.io/>.

### Building the image

The build the image you give the template a script which has all the
customizations:

```shell
packer init .
packer build -var customize_script=my-changes.sh -var ubuntu_series=jammy \
    -only='cloudimg.*' .
```

`my-changes.sh` is a script you write which customizes the image from within
the VM. For example, you can install packages using `apt-get`, call out to
ansible, or whatever you want.

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
packer build -var kernel=linux-lowlatency -var customize_script=my-changes.sh \
    -only='cloudimg.*' .
```

You can also install the kernel manually in your `my-changes.sh` script, but in
that case you also need to write the name of the kernel package to
`/curtin/CUSTOM_KERNEL`. This is to ensure that MAAS won't install another
kernel on deploy.

### Building different architectures

By default, images are produces for amd64. You can build for arm64 as well if
you specify the `architecture` parameter:

```shell
packer init .
packer build -var architecture=arm64 -var customize_script=my-changes.sh \
    -only='cloudimg.*' .
```

## ubuntu-flat.pkr.hcl and ubuntu-lvm.pkr.hcl

These templates use an Ubuntu server image to install the image to the VM. It
takes longer than using a cloud image, but can be useful for certain use cases.

### Customizing the Image

It is possible to customize the image either during the Ubuntu installation or afterwards, before packing the final image. The former is done by providing [autoinstall config](https://ubuntu.com/server/docs/install/autoinstall), editing the _user-data-flat_ and _user-data-lvm_ files. The latter is performed by the _install-custom-packages_ script.

### Building the image using a proxy

The Packer template downloads the Ubuntu net installer from the Internet. To tell Packer to use a proxy set the HTTP_PROXY environment variable to your proxy server. Alternatively you may redefine iso_url to a local file, set iso_checksum_type to none to disable checksuming, and remove iso_checksum_url.

### Building an image

You can easily build the image using the Makefile:

```shell
make custom-ubuntu-lvm.dd.gz
```

to build a raw image with LVM, alternatively, you can build a TGZ image

```shell
make custom-ubuntu.tar.gz
```

You can also manually run packer. Your current working directory must
be in packer-maas/ubuntu, where this file is located. Once in
packer-maas/ubuntu you can generate an image with:

```shell
packer init .
PACKER_LOG=1 packer build -only=qemu.lvm .
```

or

```shell
packer init .
PACKER_LOG=1 packer build -only=qemu.flat .
```

Note: ubuntu-lvm.pkr.hcl and ubuntu-flat.pkr.hcl are configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or change the value of headless to false in the HCL2 file.

Installation is non-interactive.  Note that the installation will attempt an SSH connection to the QEMU VM where the newly-built image is being booted.  This is the final provisioning step in the process.  Packer uses SSH to discover that the image has, in fact, booted, so there may be a number of failed tries -- over 3-5 minutes -- until the connection is successful.  This is normal behavior for packer.

### Default Username

The default username is ```ubuntu```

## Uploading images to MAAS

TGZ image

```shell
maas admin boot-resources create \
    name='custom/ubuntu-tgz' \
    title='Ubuntu Custom TGZ' \
    architecture='amd64/generic' \
    filetype='tgz' \
    content@=custom-cloudimg.tar.gz
```

LVM raw image

```shell
maas admin boot-resources create \
    name='custom/ubuntu-raw' \
    title='Ubuntu Custom RAW' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=custom-ubuntu-lvm.dd.gz
```
