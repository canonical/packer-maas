# Packer MAAS

[Packer](http://packer.io) [templates](https://www.packer.io/docs/templates/index.html),
associated scripts, and configuration for creating deployable OS images for [MAAS](http://maas.io).

See README.md in each directory for documentation on how to customize, build,
and upload images.

## Git Submodules
Packer MAAS uses git submodules to retrieve required resource files during
image building. Packer MAAS and all submodules can be cloned at once with:

```
$ git clone --recurse-submodules  git+ssh://ltrager@git.launchpad.net/~maas-committers/+git/packer-maas
```

If Packer MAAS has already been checked out submodules can be retrieved with

```
$ git submodule init
$ git submodule update
```