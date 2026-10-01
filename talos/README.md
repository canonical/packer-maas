# Talos Packer Template for MAAS

## Introduction

Builds a Talos Linux disk image from [Talos Image Factory](https://factory.talos.dev) and packages it
for upload to [MAAS](https://maas.io) as a custom image (`ddgz`).

Unlike the Canonical [packer-maas](https://github.com/canonical/packer-maas) templates, this does not
boot an installer in QEMU. Talos has no installer to script and no SSH, so Packer's `null` source
downloads the prebuilt raw disk image from Image Factory and recompresses it as a gzipped raw disk.
No NBD or loop devices are involved.

## How it works

1. The schematic YAML is generated from the Packer variables (extensions, extra kernel args).
2. The YAML is POSTed to Image Factory, which returns the schematic ID (a content hash, so the same
   inputs always give the same ID).
3. The `<platform>-<arch>.raw.zst` image for that ID and version is downloaded and decompressed.
4. The raw disk is gzipped to `talos-<version>-<arch>.raw.gz`.

## Prerequisites (to create the image)

* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* packages: `curl`, `jq`, `zstd`, `gzip`

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.5+

## Customizing the Image

The deployment image may be customized by changing the default architecture and extensions.

## Building an image

You can easily build the image using the Makefile:

```shell
make                                   # talos-v1.14.2-amd64.raw.gz
make TALOS_VERSION=v1.14.1
make ARCH=arm64
make EXTENSIONS="siderolabs/iscsi-tools siderolabs/util-linux-tools"
make upload                            # push to MAAS
make clean                             # remove built images
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/talos, where this file is located. Once in packer-maas/talos
you can generate an image with:

```shell
packer init .
PACKER_LOG=1 packer build .
```

### Makefile Parameters

| Make variable | Default | Description |
|---|---|---|
| `TALOS_VERSION` | `v1.14.2` | Talos release |
| `ARCH` | `amd64` | `amd64` or `arm64` |
| `PLATFORM` | `metal` | Image Factory name for bare metal |
| `EXTENSIONS` | (none) | Space-separated official system extensions |
| `MAAS_PROFILE` | `admin` | MAAS CLI profile |
| `MAAS_NAME` | `custom/talos` | Boot resource name in MAAS |

## Uploading an image to MAAS

```shell
make upload
# or manually
maas $PROFILE boot-resources create \
    name='custom/talos' title='Talos v1.14.2' \
    architecture='amd64/generic' filetype='ddgz' \
    content@=talos-v1.14.2.raw.gz
```
