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
  default     = "centos9.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos9_iso_url" {
  type    = string
  default = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20230508.0-x86_64-boot.iso"
}

variable "centos9_sha256sum_url" {
  type    = string
  default = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20230508.0-x86_64-boot.iso.MD5SUM"
}

source "qemu" "centos9" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos9.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.centos9_sha256sum_url}"
  iso_url          = var.centos9_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.centos9"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=centos9",
      "source ../scripts/setup-nbd",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
