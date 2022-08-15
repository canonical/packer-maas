# Rocky 9 Packer template for MAAS

## Introduction

The Packer template in this directory creates a Rocky 9 AMD64 image for use with MAAS.

## Prerequisites to create the image

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines and with a CPU that supports x86-64-v2 extensions
* qemu-utils
* [Packer.](https://www.packer.io/intro/getting-started/install.html)

## Requirements to deploy the image

* [MAAS](https://maas.io) 3.2.1 or later, as Rocky support is introduced in that version
* [Curtin](https://launchpad.net/curtin) 22.1. If you have an earlier MAAS version, you can [patch](https://code.launchpad.net/~xnox/curtin/+git/curtin/+merge/415604) distro.py to deploy Rocky.

## Customizing the image

You can customize the deployment image by modifying http/rocky.ks. See the [RHEL kickstart documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_an_advanced_rhel_installation/kickstart-commands-and-options-reference_installing-rhel-as-an-experienced-user#part-or-partition_kickstart-commands-for-handling-storage) for more information.

## Building the image using a proxy

The Packer template downloads the Rocky ISO image from the Internet. You can tell Packer to use a proxy by setting the HTTP_PROXY environment variable to point to your proxy server. You can also  redefine rocky_iso_url to a local file. If you want to skip the base image integrity check, set iso_checksum_type to none and remove iso_checksum.

You can add the --proxy=$HTTP_PROXY flag to every line starting with url in http/rocky.ks to use a proxy during installation.

## Building an image

You can build the image using the Makefile:

```shell
make
```

You can also manually run packer. Set your current working directory to packer-maas/rocky9, where this file resides, and generate an image with:

```shell
sudo PACKER_LOG=1 packer build .
```

The installation runs in a non-interactive mode.

Note: rocky9.pkr.hcl runs Packer in headless mode, with the serial port output from qemu redirected to stdio to give feedback on image creation process. If you wish to see more, change the value of `headless` to `false` in rocky9.pkr.hcl, remove `[ "-serial", "stdio" ]` from `qemuargs` section and select `View`, then `serial0` in the qemu window that appears during build. This lets you watch progress of the image build script. Press `ctrl-b 2` to switch to shell to explore more, and `ctrl-b 1` to go back to log view.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='custom/rocky9' title='Rocky 9 Custom' \
    architecture='amd64/generic' base_image='rhel/9' filetype='tgz' \
    content@=rocky9.tar.gz
```

## Default username

MAAS uses cloud-init to create ```cloud-user``` account using the ssh keys configured for the MAAS admin user (e.g. imported from Launchpad). Log in to the machine:

```shell
ssh -i ~/.ssh/<your_identity_file> cloud-user@<machine-ip-address>
```

Next to that, the kickstart script creates an account with both username and password set to  ```rocky```. Note that the default sshd configuration in Rocky 9 disallows password-based authentication when logging in via ssh, so trying `ssh rocky@<machine-ip-address>` will fail. Password-based authentication can be enabled by having `PasswordAuthentication yes` in /etc/ssh/sshd_config after logging in with ```cloud-user```. Perhaps there is a way to make that change using kickstart script, but it is not obvious as ```anaconda```, the installer, makes its own changes to sshd_config file during installation. If you know how to do this, a PR is welcome.
