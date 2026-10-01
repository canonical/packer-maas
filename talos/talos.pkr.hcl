# talos.pkr.hcl
packer {
  required_version = ">= 1.9.0"
}

variable "talos_version" {
  type    = string
  default = "v1.14.2"
}

variable "arch" {
  type    = string
  default = "amd64"
}

# Image Factory calls bare-metal "metal"
variable "platform" {
  type    = string
  default = "metal"
}

variable "extensions" {
  type    = list(string)
  default = []   # e.g. ["siderolabs/iscsi-tools", "siderolabs/util-linux-tools"]
}

variable "extra_kernel_args" {
  type    = list(string)
  default = []
}

locals {
  schematic = yamlencode({
    customization = merge(
      length(var.extra_kernel_args) > 0 ? { extraKernelArgs = var.extra_kernel_args } : {},
      length(var.extensions) > 0 ? { systemExtensions = { officialExtensions = var.extensions } } : {}
    )
  })
}

source "null" "talos" {
  communicator = "none"
}

build {
  name    = "talos"
  sources = ["source.null.talos"]

  provisioner "shell-local" {
    environment_vars = [
      "SCHEMATIC=${local.schematic}",
      "VERSION=${var.talos_version}",
      "ARCH=${var.arch}",
      "PLATFORM=${var.platform}",
    ]
    inline = [
      "set -euo pipefail",
      "ID=$(printf '%s' \"$SCHEMATIC\" | curl -fsS -X POST --data-binary @- https://factory.talos.dev/schematics | jq -r .id)",
      "echo \"Schematic ID: $ID\"",
      "curl -fL -o talos.raw.zst https://factory.talos.dev/image/$ID/$VERSION/$PLATFORM-$ARCH.raw.zst",
      "zstd -d -f talos.raw.zst -o talos.raw",
      "gzip -c talos.raw > talos-$VERSION-$ARCH.raw.gz",
      "rm -f talos.raw talos.raw.zst",
    ]
  }
}
