# Building Custom Images for MAAS with Packer

This repository provides [Packer](https://developer.hashicorp.com/packer) templates, scripts, and configuration to build custom operating system images for [MAAS](https://maas.io).  

Use these templates if you need:
- **Custom Ubuntu images** with pre-installed packages, security hardening, or organization-specific tweaks.  
- **Non-Ubuntu images** (RHEL, CentOS, SLES, Windows, ESXi, etc.) that MAAS does not provide out-of-the-box.  
- A **repeatable, automated build process** for images you can upload into MAAS.  

> ⚠️ If you only need stock Ubuntu images, see the [How to manage images](https://canonical.com/maas/docs/how-to-manage-images) guide instead.

---

## Why build custom images?

- **Consistency**: Standardize environments across your MAAS deployments.  
- **Control**: Add, remove, or patch software before deployment.  
- **Compliance**: Ensure security and audit requirements are met.  
- **Coverage**: Deploy non-Ubuntu operating systems through MAAS.  

MAAS relies on these images when commissioning, deploying, and testing machines. Custom images let you tailor exactly what gets deployed.

---

## Prerequisites

Before building an image, prepare a build environment:

- An Ubuntu host or VM with:
  - 4 CPU cores  
  - 8 GB RAM  
  - 25 GB free storage  
  - Hardware-assisted virtualization enabled  
- [Packer installed](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli#installing-packer)  
- (Optional) QEMU with GUI if you want to see builds interactively  

Verify Packer is installed:

```bash
packer version
```

---

## How to build and upload a custom image

Follow these steps to build and make an image available in MAAS.

### 1. Clone this repository

```bash
git clone https://github.com/canonical/packer-maas.git
cd packer-maas
```

### 2. Select a template

Each supported operating system has its own directory with:
- One or more **HCL2 templates**  
- A `scripts/` directory with helper scripts  
- An `http/` directory with auto-configuration files  
- A `README.md` explaining OS-specific details  
- A `Makefile` for convenience  

See the [Existing templates](#existing-templates) table below for the full list.  

### 3. Build the image

Run Packer from within the template directory. Example for Ubuntu:

```bash
cd ubuntu
packer build ubuntu.pkr.hcl
```

For debugging, use:

```bash
PACKER_LOG=1 packer build ubuntu.pkr.hcl
```

If you want to view the VM build process:
- Remove `"headless": true` from the template  
- Or connect via VNC using the IP/port shown during build  

### 4. Upload the image to MAAS

After building, upload the image to your MAAS region controller:

```bash
maas $PROFILE boot-resources create name='custom/ubuntu-24.04'     title='Ubuntu 24.04 Custom'     architecture='amd64/generic'     filetype='tgz'     content@=ubuntu-24.04-custom.tgz
```

> ℹ️ Commands vary slightly by OS — see the template’s `README.md` for exact syntax.

### 5. Verify in MAAS

Check that the image is available:

```bash
maas $PROFILE boot-resources read | grep custom
```

Then deploy a test machine with the new image and confirm you can log in.

---

### Ubuntu example (quick start)

Here’s a complete example for building and uploading a custom Ubuntu image.

1. **Install dependencies**

```shell
sudo apt update
sudo apt install packer qemu-utils qemu-system ovmf cloud-image-utils
````

2. **Clone the Packer MAAS repository**

```shell
git clone https://github.com/canonical/packer-maas.git
cd packer-maas/ubuntu
```

3. **Build an image**

Use the included `Makefile` to build an Ubuntu LVM image:

```shell
make custom-ubuntu-lvm.dd.gz
```

This may take a few minutes. Packer will boot the image in headless mode and attempt repeated SSH handshakes until provisioning succeeds.

4. **Upload the image to MAAS**

```shell
maas admin boot-resources create \
    name='custom/ubuntu-raw' \
    title='Ubuntu Custom RAW' \
    architecture='amd64/generic' \
    filetype='ddgz' \
    content@=custom-ubuntu-lvm.dd.gz
```

5. **Verify deployment**

Deploy the image to a test machine:

```shell
maas admin machines read | jq -r '(["HOSTNAME","SYSID","STATUS","OS","DISTRO"]),
(.[] | [.hostname, .system_id, .status_name, .osystem, .distro_series]) | @tsv' | column -t
```

You should see your custom image listed under `OS = custom`.

Log in with the default Ubuntu username:

```shell
ssh ubuntu@<machine-ip>
```

---

## Customizing templates

Every OS template can be adjusted to include your own configuration. Common options include:

- Adding extra packages in the provisioner step  
- Including custom cloud-init or preseed files  
- Adjusting the Packer `boot_command` to change installation behavior  
- Changing image names (`name`, `title`) to avoid cache conflicts  

Refer to the `README.md` inside each OS directory for supported parameters.  

---

## Existing templates

| **OS**            | **Maturity Level** | **Architecture**  | **MAAS Version** |
|-------------------|:------------------:|:-----------------:|:-----------------|
| [Azure Local (HCI)](windows/README.md) | Beta               | x86_64            | >= 3.3           |
| [AlmaLinux 8](alma8/README.md)       | Beta               | x86_64 / aarch64  | >= 3.3           |
| [AlmaLinux 9](alma9/README.md)       | Beta               | x86_64 / aarch64  | >= 3.3           |
| [AlmaLinux 10](alma10/README.md)     | Beta               | x86_64 / aarch64  | >= 3.3           |
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

---

## Maturity levels

- **Stable**: Tested and suitable for production.  
- **Beta**: Works in most cases but needs broader validation.  
- **Alpha**: Depends on unreleased MAAS or Curtin versions; not production-ready.  
- **EOL**: Upstream OS is no longer supported — not recommended.  

---

## Debugging builds

- Use `PACKER_LOG=1` to enable verbose logging.  
- Use `FOREGROUND=1` to keep processes in the foreground.  
- To view the build VM:
  - Remove `headless=true` in the template, or  
  - Connect via VNC using the IP/port printed during build.  

---

## Best practices for uploading images

- Follow examples in each OS’s `README.md`.  
- The `name` parameter is formatted as `prefix/os-name`. The `os-name` can include dashes, dots and numbers but no space and special characters.
- Use **unique names** for images to avoid cache collisions.  
- The `title` parameter is free text format as long as enclosed in quotes.
- Upload from a machine close to the MAAS region controller to reduce latency.  
- Test images on a small scale before wide deployment.  

---

## Contributing new templates

We welcome contributions.  

### Project structure
Each OS directory typically contains:
- One or more `.pkr.hcl` templates  
- `scripts/` for provisioning  
- `http/` for installer automation  
- A `README.md` with OS-specific instructions  
- A `Makefile` for build automation  

### Submit a new template
1. [Fork the repo](https://github.com/canonical/packer-maas/fork).  
2. Create a branch.  
3. Add a new directory or `.pkr.hcl` template.  
4. Run `packer validate .` to check.  
5. Commit and push.  
6. Open a pull request.  

---

## Next steps

- [How to manage images in MAAS](https://canonical.com/maas/docs/how-to-manage-images)  
