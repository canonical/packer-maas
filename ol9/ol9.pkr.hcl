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
  default     = "ol9.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "ol9_iso_url" {
  type    = string
  default = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u2/x86_64/OracleLinux-R9-U2-x86_64-boot.iso"
}

variable "ol9_sha256sum_path" {
  type    = string
  default = "https://linux.oracle.com/security/gpg/checksum/OracleLinux-R9-U2-Server-x86_64.checksum"
}

source "qemu" "ol9" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ol9.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.ol9_sha256sum_path}"
  iso_url          = var.ol9_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.ol9"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=ol9",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
