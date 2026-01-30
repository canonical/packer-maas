# Ubuntu Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates Ubuntu images for use with MAAS.

This templates supports building amd64 and arm64 images in all three supported
modes including, cloudimg, flat as wellas lvm.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* qemu-system
* qemu-system-modules-spice (If building on Ubuntu 24.04 LTS "Noble")
* ovmf
* cloud-image-utils
* parted
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

Building using make:

```shell
make custom-cloudimg.tar.gz SERIES=jammy
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

### Customization example: BlueField DPU

Examples of how to use the _customize_script_ to build an image for
BlueField DPUs are provided. The kernel and packages installed by the
customization script require the use of _jammy_ as Ubuntu series when targeting
a DOCA release lower than `3.2.0`.

```shell
make custom-cloudimg.tar.gz SERIES=jammy ARCH=arm64 CUSTOMIZE=scripts/examples/bluefield-doca-2-9-3.sh
make custom-cloudimg.tar.gz SERIES=noble ARCH=arm64 CUSTOMIZE=scripts/examples/bluefield-doca-3-2-1.sh
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

### Makefile Parameters

#### PACKER_LOG

Enable (1) or Disable (0) verbose packer logs. The default value is set to 0.

#### SERIES

Specify the Ubuntu Series to build. The default value is set to Jammy.

#### ARCH

Target image architecture. Supported values are amd64 (default) and arm64.

#### URL

The URL prefix for mirror that is hosting the ISO images for a given series. The default value is set to http://releases.ubuntu.com. ISO images are expected to be under URL/SERIES/.

#### SUMS

The file name for the checksums file. The default value is set to SHA256SUMS.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

#### CUSTOMIZE

When specified, use the provided file to customize the content of ubuntu-cloudimg.

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
