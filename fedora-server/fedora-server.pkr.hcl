packer {
  required_version = ">= 1.11.0"
  required_plugins {
    qemu = {
      version = ">= 1.1.0, < 1.1.2"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "filename" {
  type        = string
  default     = "fedora-server.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "fedora_iso_path" {
  type    = string
  default = "${env("FEDORA_SERVER_ISO_PATH")}"
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

variable "host_is_arm" {
  type        = bool
  default     = false
  description = "The host architecture is aarch64"
}

variable "ovmf_suffix" {
  type        = string
  default     = ""
  description = "Suffix for OVMF CODE and VARS files. Newer systems such as Noble use _4M."
}

variable "version" {
  type    = string
  default = "42"
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
    "aarch64" = var.host_is_arm ? "virt,accel=kvm" : "virt"
  }
  qemu_cpu = {
    "x86_64"  = "host"
    "aarch64" = var.host_is_arm ? "host" : "max"
  }
}


source "qemu" "fedora-server" {
  boot_command     = ["<up><wait>", "e", "<down><down><down><left>", " console=ttyS0 inst.cmdline inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/fedora-server.ks <f10>"]
  boot_wait        = "5s"
  communicator     = "none"
  disk_size        = "8G"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.fedora_iso_path
  memory           = 2048
  cpus             = 4
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
    ["-drive", "file=output-fedora-server/packer-fedora-server,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=${var.fedora_iso_path},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_content = {
    "/fedora-server.ks" = templatefile("${path.root}/http/fedora-server.ks.pkrtpl.hcl",
      {
        KS_VERSION = var.version,
        KS_ARCH    = "${lookup(local.qemu_arch, var.architecture, "")}",
      }
    )
  }
}

build {
  sources = ["source.qemu.fedora-server"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=${source.name}",
      "OUTPUT=${var.filename}",
      "ROOT_PARTITION=2",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root",
      "rm -rf output-${source.name}",
    ]
    inline_shebang = "/bin/bash -e"
  }
}
