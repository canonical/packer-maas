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
  default     = "centos7.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos7_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso"
}

variable "centos7_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/7/isos/x86_64/sha256sum.txt"
}

source "qemu" "centos7" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos7.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.centos7_sha256sum_url}"
  iso_url          = var.centos7_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.centos7"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=centos7",
      "source ../scripts/setup-nbd",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
