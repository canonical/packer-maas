# Packer MAAS

[Packer](https://developer.hashicorp.com/packer) [templates](https://developer.hashicorp.com/packer/docs/templates),
associated scripts, and configuration for creating deployable OS images for [MAAS](http://maas.io).

See [installing-packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli#installing-packer) to get it installed on the builder machine.

See README.md in each directory for documentation on how to customize, build,
and upload images.

Read more about how [custom images](https://canonical.com/maas/docs/how-to-build-custom-images) work.

## Existing templates

| **OS**            | **Maturity Level** | **Architecture**  | **MAAS Version** |
|-------------------|:------------------:|:-----------------:|:-----------------|
| [Azure Local (HCI)](windows/README.md) | Beta               | x86_64            | >= 3.3           |
| [AlmaLinux 8](alma8/README.md)       | Beta               | x86_64            | >= 3.5           |
| [AlmaLinux 9](alma9/README.md)       | Beta               | x86_64            | >= 3.5           |
| [AzureLinux 2.0](azurelinux/README.md)    | Beta               | x86_64            | >= 3.3           |
| [CentOS 6](centos6/README.md)          | EOL                | x86_64            | >= 1.6           |
| [CentOS 7](centos7/README.md)          | EOL                | x86_64            | >= 2.3           |
| [CentOS 8](centos8/README.md)          | EOL                | x86_64            | >= 2.7           |
| [CentOS 8 Stream](centos8-stream/README.md)   | Beta               | x86_64            | >= 3.2           |
| [CentOS 9 Stream](centos9-stream/README.md)   | Beta               | x86_64            | >= 3.2           |
| [Debian 10](debian/README.md)         | EOL                | x86_64 / aarch64  | >= 3.2           |
| [Debian 11](debian/README.md)         | Beta               | x86_64 / aarch64  | >= 3.2           |
| [Debian 12](debian/README.md)         | Beta               | x86_64 / aarch64  | >= 3.2           |
| [Debian 13](debian/README.md)         | Beta               | x86_64 / aarch64  | >= 3.2           |
| [Fedora Server 41](fedora-server/README.md)         | Beta               | x86_64 / aarch64  | >= 3.2           |
| [Fedora Server 42](fedora-server/README.md)         | Beta               | x86_64 / aarch64  | >= 3.2           |
| [OL8](ol8/README.md)               | Alpha              | x86_64            | >= 3.5           |
| [OL9](ol9/README.md)               | Alpha              | x86_64            | >= 3.5           |
| [RHEL 7](rhel7/README.md)            | EOL                | x86_64            | >= 2.3           |
| [RHEL 8](rhel8/README.md)            | Stable             | x86_64 / aarch64  | >= 2.7           |
| [RHEL 9](rhel9/README.md)            | Beta               | x86_64 / aarch64  | >= 3.3           |
| [RHEL 10](rhel10/README.md)           | Beta               | x86_64 / aarch64  | >= 3.3           |
| [Rocky 8](rocky8/README.md)           | Beta               | x86_64 / aarch64  | >= 3.3           |
| [Rocky 9](rocky9/README.md)           | Beta               | x86_64 / aarch64  | >= 3.3           |
| [SLES 12](sles12/README.md)           | Beta               | x86_64            | >= 3.4           |
| [SLES 15](sles15/README.md)           | Beta               | x86_64 / aarch64  | >= 3.3           |
| [SLES 16](sles16/README.md)           | Alpha              | x86_64 / aarch64  | >= 3.3           |
| [Ubuntu](ubuntu/README.md)            | Stable             | x86_64 / aarch64  | >= 3.0           |
| [VMWare ESXi 6](vmware-esxi/README.md)     | EOL                | x86_64            | >= 3.0           |
| [VMWare ESXi 7](vmware-esxi/README.md)     | Stable             | x86_64            | >= 3.0           |
| [VMWare ESXi 8](vmware-esxi/README.md)     | Beta               | x86_64            | >= 3.0           |
| [VMWare ESXi 9](vmware-esxi/README.md)     | Beta               | x86_64            | >= 3.0           |
| [Windows 2016](windows/README.md)      | Beta               | x86_64            | >= 3.3           |
| [Windows 2019](windows/README.md)      | Beta               | x86_64            | >= 3.3           |
| [Windows 2022](windows/README.md)      | Beta               | x86_64            | >= 3.3           |
| [Windows 2025](windows/README.md)      | Beta               | x86_64            | >= 3.3           |
| [Windows 10](windows/README.md)        | Beta               | x86_64            | >= 3.3           |
| [Windows 11](windows/README.md)        | Beta               | x86_64            | >= 3.3           |
| [XenServer 8](xenserver8/README.md)       | Beta               | x86_64            | >= 3.3           |
| [XCP-ng 8.x](xenserver8/README.md)        | Beta               | x86_64            | >= 3.3           |

### Maturity level

* Templates marked as *EOL* are OSes that are no longer supported by the upstream maintainer, and **are not recommended for new deployments**. These systems don't receive security updates and mirrors can become permanently offline at any moment.
* *Alpha* templates require packages that are not yet generally available, e.g. an unreleased MAAS or Curtin version. These should not be used in production environments.
* *Beta* templates should work but we still don't have enough successful deployment reports to regard it as *Stable*.

## Hardware Requirement

A physical or virtual machine capable of accelerated virtualization, with 4 CPU cores, 8GB of RAM and 25GB or storage is recommended.

### Output & Debugging

All templates are configured to output to serial. Packer does not officially
support serial output([GH:5](https://github.com/hashicorp/packer-plugin-qemu/issues/5)).
To see output run with `PACKER_LOG=1`.

If you wish to use a GUI modify each template as follows:

* Remove any boot_command line that contains "console" or "com1_Port"
* Remove ""-serial", "stdio"" from qemuargs. qemuargs may be removed as well if empty.

If you wish to use QEMU's UI also remove "headless": true

If you keep "headless": true you can connect using VNC. Packer prints the IP and port
number to connect upon execution.

For additional visibility for debugging, use `FOREGROUND=1` in combination with `PACKER_LOG=1`.

## Best practices and notes for uploading images

* Model upload commands after example(s) provided in target OS template README.md files. There are small but important variations depending on the image type and format.
* The `name` parameter is formatted as `prefix/os-name` and the `os-name` part can include dashes, dots and numbers but no space and special characters.
* It is highly recommended to use unique `name` values for images to avoid potential caching overlaps and such.
* The `title` parameter is free text format as long as enclosed in quotation marks.
* Refrain from uploading images from distant remote locations involving high latency. This slows down the process and has potential for failures.
* To reduce latency issues, transfer built images to a machine adjacent to MAAS Region controller(s) or directly to a Region controller and upload.

## Contributing new templates

We welcome contributions of new templates.

The following is a set of guidelines for contributing to Packer MAAS. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

### Project structure

Each OS has it's own directory in the repository. The typical contents is:

* one or more HCL2 templates
* a `scripts` directory with auxiliary scripts required by `provisioner` and `post-processor` blocks
* a `http` directory with auto-configuration files used by the OS installer
* a `README.md` file describing:
  * What is the target OS
  * Host requirements for building this template
  * MAAS requirements for deploying the generated image
  * Description of each template (HCL2) file, including the use of all parameters defined by them
  * Step by step instruction to build it
  * Default login credentials for the image (if any)
  * Instructions for uploading this image to MAAS
  * Any other applicable details and considerations
* a `Makefile` to build the template

### How to submit a new template

1. [Fork the project](https://github.com/canonical/packer-maas/fork) to your own GH account
2. Create a local branch
3. If you are contributing a new OS, create a new directory following the guidelines above
4. If you are creating a new template for an already supported OS, just create a HCL2 file and add auxiliary files it requires to the appropriate directories
5. Run `packer validate .` in the directory to check your template
6. Commit your changes and push the branch to your repository
7. Open a Merge Request to `packer-maas`
8. Wait for review
