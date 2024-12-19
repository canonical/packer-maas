packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "filename" {
  type        = string
  default     = "rhel8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "rhel8_iso_path" {
  type    = string
  default = "${env("RHEL8_ISO_PATH")}"
}

# Use --baseurl to specify the exact url for AppStream repo
variable "ks_appstream_repos" {
  type    = string
  default = "--baseurl='file:///run/install/repo/AppStream'"
}

variable ks_proxy {
  type    = string
  default = "${env("KS_PROXY")}"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "ovmf_suffix" {
  type        = string
  default     = ""
  description = "Suffix for OVMF CODE and VARS files. Newer systems such as Noble use _4M."
}

locals {
  qemu_arch = {
    "x86_64"  = "x86_64"
    "aarch64" = "aarch64"
  }
  uefi_imp = {
    "x86_64"  = "OVMF"
    "aarch64" = "AAVMF"
  }
  uefi_sfx = {
    "x86_64"  = "${var.ovmf_suffix}"
    "aarch64" = ""
  }
  qemu_machine = {
    "x86_64"  = "accel=kvm"
    "aarch64" = "virt"
  }
  qemu_cpu = {
    "x86_64"  = "host"
    "aarch64" = "max"
  }
  ks_proxy    = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
}


source "qemu" "rhel8" {
  boot_command     = ["<up><wait>", "e", "<down><down><down><left>", " console=ttyS0 inst.cmdline inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rhel8.ks <f10>"]
  boot_wait        = "5s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.rhel8_iso_path
  memory           = 2048
  cores            = 4
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"
  qemuargs = [
    ["-serial", "stdio"],
    ["-boot", "strict=off"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    ["-device", "virtio-net-pci,netdev=net0"],
    ["-netdev", "user,id=net0"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-gpu-pci"],
    ["-global", "driver=cfi.pflash01,property=secure,value=off"],
    ["-drive", "if=pflash,format=raw,unit=0,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE${lookup(local.uefi_sfx, var.architecture, "")}.fd"],
    ["-drive", "if=pflash,format=raw,unit=1,id=ovmf_vars,file=${var.architecture}_VARS.fd"],
    ["-drive", "file=output-rhel8/packer-rhel8,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=${var.rhel8_iso_path},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_content = {
    "/rhel8.ks" = templatefile("${path.root}/http/rhel8.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_APPSTREAM_REPOS = var.ks_appstream_repos,
      }
    )
  }
}

build {
  sources = ["source.qemu.rhel8"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=${source.name}",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root",
      "rm -rf output-${source.name}",
    ]
    inline_shebang = "/bin/bash -e"
  }
}
