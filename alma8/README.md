# Alma 8 Packer template for MAAS

## Introduction

The Packer template in this directory creates a Alma 8 AMD64 image for use with MAAS.

## Prerequisites to create the image

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements to deploy the image

* [MAAS](https://maas.io) 3.5 or later, as that version introduces support for Alma
* [Curtin](https://launchpad.net/curtin) 23.1 or later. If you have a MAAS with an earlier Curtin version, you can [patch](https://code.launchpad.net/~alexsander-souza/curtin/+git/curtin/+merge/462367) distro.py to deploy Alma.

## Customizing the image

You can customize the deployment image by modifying http/alma.ks. See the [RHEL kickstart documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_an_advanced_rhel_installation/kickstart-commands-and-options-reference_installing-rhel-as-an-experienced-user#part-or-partition_kickstart-commands-for-handling-storage) for more information.

## Building the image using a proxy

The Packer template downloads the Alma ISO image from the Internet. You can tell Packer to use a proxy by setting the HTTP_PROXY environment variable to point to your proxy server. You can also redefine alma_iso_url to a local file. If you want to skip the base image integrity check, set iso_checksum_type to none and remove iso_checksum.

To use a proxy during the installation define the `KS_PROXY` variable in the environment, as bellow:

```shell
export KS_PROXY="\"${HTTP_PROXY}\""
```

# Building the image using a kickstart mirror

To tell Packer to use a specific mirror set the `KS_MIRROR` environment variable
poiniting to the mirror URL.

```shell
export KS_MIRROR="https://repo.almalinux.org/almalinux/8"
```

## Building an image

You can build the image using the Makefile:

```shell
make
```

You can also manually run packer. Set your current working directory to packer-maas/alma8, where this file resides, and generate an image with:

```shell
packer init
PACKER_LOG=1 packer build .
```

The installation runs in a non-interactive mode.

Note: alma8.pkr.hcl runs Packer in headless mode, with the serial port output from qemu redirected to stdio to give feedback on image creation process. If you wish to see more, change the value of `headless` to `false` in alma8.pkr.hcl, remove `[ "-serial", "stdio" ]` from `qemuargs` section and select `View`, then `serial0` in the qemu window that appears during build. This lets you watch progress of the image build script. Press `ctrl-b 2` to switch to shell to explore more, and `ctrl-b 1` to go back to log view.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create name='custom/alma8' \
    title='Alma 8 Custom' architecture='amd64/generic' \
    base_image='rhel/8' filetype='tgz' \
    content@=alma8.tar.gz
```

## Default username

MAAS uses cloud-init to create ```cloud-user``` account using the ssh keys configured for the MAAS admin user (e.g. imported from Launchpad). Log in to the machine:

```shell
ssh -i ~/.ssh/<your_identity_file> cloud-user@<machine-ip-address>
```

Next to that, the kickstart script creates an account with both username and password set to  ```alma```. Note that the default sshd configuration in Alma 8 disallows password-based authentication when logging in via ssh, so trying `ssh alma@<machine-ip-address>` will fail. Password-based authentication can be enabled by having `PasswordAuthentication yes` in /etc/ssh/sshd_config after logging in with ```cloud-user```. Perhaps there is a way to make that change using kickstart script, but it is not obvious as ```anaconda```, the installer, makes its own changes to sshd_config file during installation. If you know how to do this, a PR is welcome.
