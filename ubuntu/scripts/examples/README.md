# BlueField Customization Scripts

This directory contains example customization scripts for building
BlueField DPU images with packer-maas.

| Script | DOCA | BSP | Kernel | Series | Notes |
|--------|------|-----|--------|--------|-------|
| `bluefield-doca-2-9-3.sh` | 2.9.3 | 4.13.1-13827 | 6.8.0-1013 | jammy | Uses GPG key verification |
| `bluefield-doca-3-2-1.sh` | 3.2.1 | 4.13.1-13827 | 6.8.0-1013 | noble | Uses GPG key verification |
| `bluefield-doca-3-3-0.sh` | 3.3.0 | 4.14.0-13878 | 6.8.0-1016 | noble | Uses [trusted=yes] as GPG key is unavailable |

Build command:

```shell
make custom-cloudimg.tar.gz SERIES=<series> ARCH=arm64 CUSTOMIZE=scripts/examples/<script>

Refer to [ubuntu/README.md](../README.md) for full build instructions.
