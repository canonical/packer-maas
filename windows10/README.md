# Windows 10 Packer Templates for MAAS

## Introduction

The Packer templates in this directory creates Windows 10 images for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils
* qemu-system
* ovmf
* [wimlib-tools](https://wimlib.net/)
* [cloudbase-init](https://cloudbase.it/cloudbase-init/#download), v1.1.4 or newer
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html), v2.15.4 or newer
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.9.4 or newer
* [Windows 10 enterprise iso](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise), 22H2 or newer
* [virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/?C=M;O=D), v0.1.240-1 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.0+

### Building the image

Before you can go about building the image there are a few thing to setup.
1. Go get a [Windows 10 Enterprise Evaluation iso](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise) and save it to the ./iso directory
2. Replace the path to the iso in the variables.auto.pkrvars.hcl
3. Generate a sha256 checksum of the windows 10 Enterprise ISO using the command ` sha256sum ./iso/[YOUR_WINDOWS_ISO]` and replace the value in variables.auto.pkrvars.hcl
4. Get the latest [virtio-win iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/?C=M;O=D) drivers from redhat and save them to the ./iso directory. Alternativley run the `windows10/scripts/DownloadLatestVirtio-Win.sh` script to get the latest version automatically.


#### Accessing external files from you script

If you want to put or use some files in the image, you can put those in the `http` directory.

Whatever file you put there, you can access from within your script like this:

```shell
wget http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}:/my-file
```

### Customizing the Image

It is possible to make a custom windows image based on an iso file using the `make custom-win10.dd.gz ISO_PATH="./iso/your_iso"`

This will read your iso file's install.wim and prompt you to select the desired windows image which will then be updated in the Autounattend.xml file.
you can also pass the name of the windows image and the product key through the `make custom-win10.dd.gz` command.

Example:

`make custom-win10.dd.gz ISO_PATH="./iso/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso" WINDOWS_IMAGE="Windows 10 Enterprise Evaluation" PRODUCT_KEY="12345-12345-12345-12345-12435"`

### Customizing the Image DEPRECATED INFORMATION

It is possible to customize the image either during the Windows installation or afterwards, before packing the final image. The former is done by editing the [Autounattend.xml](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-10) file.
The latter is performed by the collection of ansible playbooks under `./ansible`.

To edit the Autounattend.xml for another windows 10 .iso you must change the file in two key places. 
- First being the windows image to be installed. Look for more info under windowsPE >> Microsoft-Windows-Setup component. Look for the comments above the \<InstallFrom\> xml tag. 
- The second is the product key which is not nessacery. It is also in the windowsPE >> Microsoft-Windows-Setup component, look for the comments under the \<UserData\> xml tag.

This is just the bare minimum, there is a lot of default variables used in the Autounattend.xml file provideded here that you will want to explore. Id recomend getting [Windows System Image Manager](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/windows-system-image-manager-technical-reference) and reading through Kari Finn's [tutorials](https://www.tenforums.com/tutorials/96683-create-media-automated-unattended-install-windows-10-a.html) on tenfourms.com

### Building an image

You can easily build the image using the Makefile:

```shell
make win10.dd.gz
```

You can also manually run packer. Your current working directory must
be in packer-maas/windows10, where this file is located. Once in
packer-maas/ubuntu you can generate an image with:

```shell
packer init .
PACKER_LOG=1 packer build -only=qemu.win10 .
```

Note: windows10.pkr.hcl is configured to run Packer in headless mode. Only Packer output will be seen. If you wish to see the installation output connect to the VNC port given in the Packer output or change the value of headless to false in the HCL2 file.

Installation is non-interactive.  Note that the installation will attempt a WinRM connection to the QEMU VM where the newly-built image is being booted.  This marks the begening of provisioning in this process.  Packer uses WinRM to discover that the image has installed windows, booted and run through all AsynchronousCommands in the Autounattended.xml, so there will be a number of failed tries -- over 15+ minutes-- until the connection is successful.  This is normal behavior for packer.

### Default Username

The default username is ```defaultuser```

## Uploading images to MAAS

```shell
maas admin boot-resources create \
    name='custom/windows10-raw' \
    title='Windows10 Custom RAW' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=custom-win10.dd.gz
```

## Credits