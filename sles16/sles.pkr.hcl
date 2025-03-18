packer {
  required_version = ">= 1.11.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "filename" {
  type        = string
  default     = "sles16.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "sles16_iso_path" {
  type    = string
  default = "${env("SLES16_ISO_PATH")}"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}

variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "The architecture to build the image for (x86_64 or aarch64)"
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

source "qemu" "sles16" {
  boot_command      = ["e", "<down><down><down><down>", "<end><wait>", "<spacebar>", "agama.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/profile.json<wait>","<leftCtrlOn>x<leftCtrlOff>"]
  boot_wait        = "5s"
  communicator     = "none"
  disk_size        = "8G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.sles16_iso_path
  cdrom_interface  = "virtio-scsi"
  memory           = 4096
  cores            = 4
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"
  qemuargs = [
    ["-serial", "stdio"],
    ["-boot", "strict=off"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    ["-device", "virtio-net-pci,netdev=net0"],
    ["-device", "virtio-scsi-pci"],
    ["-netdev", "user,id=net0"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "scsi-cd,drive=cdrom0,bootindex=1"],
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-gpu-pci"],
    ["-global", "driver=cfi.pflash01,property=secure,value=off"],
    ["-drive", "if=pflash,format=raw,unit=0,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE${lookup(local.uefi_sfx, var.architecture, "")}.fd"],
    ["-drive", "if=pflash,format=raw,unit=1,id=ovmf_vars,file=${var.architecture}_VARS.fd"],
    ["-drive", "file=output-sles16/packer-sles16,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=${var.sles16_iso_path},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_content = {
    "/profile.json" = templatefile("${path.root}/http/profile.json.pkrtpl.hcl",
      {
        ARCH = "${lookup(local.qemu_arch, var.architecture, "")}"
      }
    )
  }
}

build {
  sources = ["source.qemu.sles16"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=sles16",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
