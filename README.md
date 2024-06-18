# Packer MAAS

[Packer](http://packer.io) [templates](https://www.packer.io/docs/templates/index.html),
associated scripts, and configuration for creating deployable OS images for [MAAS](http://maas.io).

See README.md in each directory for documentation on how to customize, build,
and upload images.

Read more about how [custom images](https://maas.io/docs/how-to-customise-images) work.

## Existing templates

| **OS**          | **Maturity Level** | **MAAS Version** |
|-----------------|:------------------:|:-----------------|
| AlmaLinux 8     | Beta               | >= 3.5           |
| AlmaLinux 9     | Beta               | >= 3.5           |
| AzureLinux 2.0  | Beta               | >= 3.3           |
| CentOS 6        | EOL                | >= 1.6           |
| CentOS 7        | Stable             | >= 2.3           |
| CentOS 8        | EOL                | >= 2.7           |
| CentOS 8 Stream | Beta               | >= 3.2           |
| CentOS 9 Stream | Beta               | >= 3.2           |
| Debian 10       | Beta               | >= 3.3           |
| Debian 11       | Beta               | >= 3.3           |
| Debian 12       | Beta               | >= 3.3           |
| OL8             | Alpha              | >= 3.5           |
| OL9             | Alpha              | >= 3.5           |
| RHEL 7          | EOL                | >= 2.3           |
| RHEL 8          | Stable             | >= 2.7           |
| RHEL 9          | Beta               | >= 3.3           |
| Rocky 8         | Beta               | >= 3.3           |
| Rocky 9         | Beta               | >= 3.3           |
| SLES 12         | Beta               | >= 3.4           |
| SLES 15         | Beta               | >= 3.4           |
| Ubuntu          | Stable             | >= 3.0           |
| VMWare ESXi 6   | EOL                | >= 3.0           |
| VMWare ESXi 7   | Stable             | >= 3.0           |
| VMWare ESXi 8   | Beta               | >= 3.0           |
| Windows 2016    | Beta               | >= 3.3           |
| Windows 2019    | Beta               | >= 3.3           |
| Windows 2022    | Beta               | >= 3.3           |
| Windows 10      | Beta               | >= 3.3           |

### Maturity level

* Templates marked as *EOL* are OSes that are no longer supported by the upstream maintainer, and **are not recommended for new deployments**. These systems don't receive security updates and mirrors can become permanently offline at any moment.
* *Alpha* templates require packages that are not yet generally available, e.g. an unreleased MAAS or Curtin version. These should not be used in production environments.
* *Beta* templates should work but we still don't have enough successful deployment reports to regard it as *Stable*.

### Output

All templates are configured to output to serial. Packer does not officially
support serial output([GH:5](https://github.com/hashicorp/packer-plugin-qemu/issues/5)).
To see output run with PACKER_LOG=1.

If you wish to use a GUI modify each template as follows:

* Remove any boot_command line that contains "console" or "com1_Port"
* Remove ""-serial", "stdio"" from qemuargs. qemuargs may be removed as well if empty.

If you wish to use QEMU's UI also remove "headless": true

If you keep "headless": true you can connect using VNC. Packer will output the
IP and port to connect to when run.

## Contributing new templates

We welcome contributions of new templates.

The following is a set of guidelines for contributing to Packer MAAS. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

### Project structure

Each OS has it's own directory in the repository. The typical contents is:

* one or more HCL2 templates
* a `scripts` directory with auxiliary scripts required by `provisioner` and `post-processor` blocks
* a `http` directory with auto-configuration files used by the OS installer
* a `README.md` file describing
  * what is the target OS
  * host requirements for building this template
  * MAAS requirements for deploying the generated image
  * description of each template (HCL2) file, including the use of all parameters defined by them
  * step by step instruction to build it
  * default login credentials for the image (if any)
  * instructions for uploading this image to MAAS
* a `Makefile` to build the template

### How to submit a new template

1. [Fork the project](https://github.com/canonical/packer-maas/fork) to your own GH account
2. Create a local branch
3. If you are contributing a new OS, create a new directory following the guidelines above
4. If you are creating a new template for an already supported OS, just create a HCL2 file and add auxiliary files it requires to the appropriate directories
5. Run `packer validate .` in the directory to check your template
6. Commit your changes and push the branch to your repository
7. Open a Merge Request to packer-maas
8. Wait for review
