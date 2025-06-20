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
  default     = "xenserver8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "headless" {
  type        = bool
  default     = true
}

variable "xenserver8_iso_path" {
  type    = string
  default = "${env("xenserver8_ISO_PATH")}"
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
  }
  uefi_imp = {
    "x86_64"  = "OVMF"
  }
  uefi_sfx = {
    "x86_64"  = "${var.ovmf_suffix}"
  }
  qemu_machine = {
    "x86_64"  = "accel=kvm"
  }
  qemu_cpu = {
    "x86_64"  = "host"
  }
}

source "qemu" "xenserver8" {
  boot_command     = ["e", "<down>", "<down>", "<down><down><left>", " answerfile=http://{{.HTTPIP}}:{{.HTTPPort}}/xenserver8.xml <f10>"]
  boot_wait        = "2s"
  communicator     = "none"
  disk_size        = "64G"
  format           = "raw"
  headless         = var.headless
  iso_checksum     = "none"
  iso_url          = var.xenserver8_iso_path
  memory           = 4096
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
    ["-drive", "file=output-xenserver8/packer-xenserver8,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    ["-drive", "file=${var.xenserver8_iso_path},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_port_min = 8100
  http_port_max = 8100
  http_content = {
    "/xenserver8.xml" = templatefile("${path.root}/http/xenserver8.xml.pkrtpl.hcl",
      {
      }
    ),
    "/xenserver8.post.sh" = templatefile("${path.root}/http/xenserver8.post.sh.pkrtpl.hcl",
      {
      }
    )
  }
}

build {
  sources = ["source.qemu.xenserver8"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=xenserver8",
      "IMG_FMT=raw",
      "source ./post.sh",
      ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "compress" {
    output = "xenserver8-lvm.dd.gz"
  }
}
