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

## Makefiles

Each directory contains a Makefile to help build the image with the correct
arguments. The default make target will remove the output-qemu directory and
previously generated image before building the new image.

The path to the Packer binary can be overridden with the `PACKER` variable:

```
$ make PACKER=/home/user/go/bin/packer
```

Images which require a user specified ISO can be set with the `ISO` variable:

```
$ make ISO=/path/to/iso
```
