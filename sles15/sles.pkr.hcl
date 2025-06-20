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
  default     = "sles15.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "sles15_iso_path" {
  type    = string
  default = "${env("SLES15_ISO_PATH")}"
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
  grub_pkgs = {
    "x86_64"  = "<package>grub2-i386-pc</package><package>grub2-x86_64-efi</package>"
    "aarch64" = "<package>grub2-arm64-efi</package>"
  }
}

source "qemu" "sles15" {
  boot_command      = ["<esc>", "e", "<down><down><down><down>", "<end><wait>", "<spacebar>", "netdevice=eth0 vga=normal netsetup=dhcp install=cd:/ lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles15.xml textmode=1<wait>","<leftCtrlOn>x<leftCtrlOff>"]
  boot_wait        = "15s"
  communicator     = "none"
  disk_size        = "4G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.sles15_iso_path
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
    ["-drive", "file=output-sles15/packer-sles15,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=${var.sles15_iso_path},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_content = {
    "/sles15.xml" = templatefile("${path.root}/http/sles15.xml.pkrtpl.hcl",
      {
        GRUB_PKGS = "${lookup(local.grub_pkgs, var.architecture, "")}"
      }
    )
  }
}

build {
  sources = ["source.qemu.sles15"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=sles15",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
