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
  default     = "centos6.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos6_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/CentOS-6.10-x86_64-netinstall.iso"
}

variable "centos6_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/sha256sum.txt"
}

source "qemu" "centos6" {
  boot_command     = ["<tab> ", "ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.centos6_sha256sum_url}"
  iso_url          = var.centos6_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.centos6"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=centos6",
      "source ../scripts/setup-nbd",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
