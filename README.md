# Packer MAAS

[Packer](http://packer.io) [templates](https://www.packer.io/docs/templates/index.html),
associated scripts, and configuration for creating deployable OS images for [MAAS](http://maas.io).

See README.md in each directory for documentation on how to customize, build,
and upload images.

## Output

All templates are configured to output to serial. Packer does not officially
support serial output([GH:9927](https://github.com/hashicorp/packer/issues/9927)).
To see output run with PACKER_LOG=1.

If you wish to use a GUI modify each template as follows:
* Remove any boot_command line that contains "console" or "com1_Port"
* Remove ""-serial", "stdio"" from qemuargs. qemuargs may be removed as well if empty.

If you wish to use QEMU's UI also remove "headless": true

If you keep "headless": true you can connect using VNC. Packer will output the
IP and port to connect to when run.

## Git Submodules
Packer MAAS uses git submodules to retrieve required resource files during
image building. Packer MAAS and all submodules can be cloned at once with:

```
$ git clone --recurse-submodules git@github.com:canonical/packer-maas.git
```

If Packer MAAS has already been checked out submodules can be retrieved with

```
$ git submodule init
$ git submodule update
```
