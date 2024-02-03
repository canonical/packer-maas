# CentOS 7 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a CentOS 7 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 2.3+
* [Curtin](https://launchpad.net/curtin) 18.1-59+

## Customizing the Image with Kickstart

The deployment image may be customized by modifying http/centos7.ks.pkrtpl.hcl. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Customizing the Image with Ansible (Optional)

Using Ansible as a provisioner in Packer, alongside modifications to the kickstart file, significantly simplifies the image-building process.
Writing complex configurations directly in the kickstart file, especially within the `%post` section, often leads to issues with escaping sequences and readability.
Inline scripts require careful handling of shell syntax, escape characters, and quotations, which can become cumbersome and error-prone for intricate configurations.
Ansible abstracts these complexities, allowing you to define configurations in a more readable and manageable YAML format.
This approach not only enhances maintainability but also reduces the risk of errors that can occur due to improper escaping or syntax issues in shell scripts.
Additionally, using Ansible as a provisioner allows for the maintenance of a single code base for provisioning across multiple operating systems.
This cross-platform capability simplifies management, reduces duplication of effort,
and ensures consistency in deployments, regardless of the operating system being provisioned.

To run Ansible provisioner following kickstart installation, perform the follwoing steps:

1. Make sure ansible is installed on the machine running packer
2. Add your ansible code to `ansible/playbook.yml`
3. Enable both ansible and ssh provisioners:

```hcl
variable enable_ssh_provisioning {
  type    = bool
  default = true
}

variable enable_ansible_provisioning {
  type    = bool
  default = true
}
```

## Building the image using a proxy

The Packer template downloads the CentOS
net installer from the Internet. To tell Packer to use a proxy set the
HTTP_PROXY environment variable to your proxy server. Alternatively you may
redefine iso_url to a local file, set iso_checksum_type to none to disable
checksuming, and remove iso_checksum_url.

To use a proxy during the installation define the `KS_PROXY` variable in the
environment, as bellow:

```shell
export KS_PROXY="\"${HTTP_PROXY}\""
```

# Building the image using a kickstart mirror

To tell Packer to use a specific mirror set the `KS_MIRROR` environment variable
poiniting to the mirror URL.

```shell
export KS_MIRROR="https://archive.kernel.org/centos-vault/7.9.2009"
```

## Building an image

You can easily build the image using the Makefile:

```shell
make
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/centos7, where this file is located. Once in
packer-maas/centos7 you can generate an image with:

```shell
packer init
PACKER_LOG=1 packer build .
```

Note: centos7.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
centos7.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='centos/7-custom' title='CentOS 7 Custom' \
    architecture='amd64/generic' filetype='tgz' \
    content@=centos7.tar.gz
```

## Default Username

The default username is ```centos```
