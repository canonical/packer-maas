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
  default     = "ol8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "ol8_iso_url" {
  type    = string
  default = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u8/x86_64/x86_64-boot.iso"
}

variable "ol8_sha256sum_path" {
  type    = string
  default = "https://linux.oracle.com/security/gpg/checksum/OracleLinux-R8-U8-Server-x86_64.checksum"
}

source "qemu" "ol8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ol8.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.ol8_sha256sum_path}"
  iso_url          = var.ol8_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.ol8"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=ol8",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
