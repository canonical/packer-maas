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
  default     = "alma9.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "headless" {
  type        = bool
  default     = true
  description = "Whether VNC viewer should not be launched."
}

variable "alma_iso_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9-latest-x86_64-boot.iso"
}

variable "alma_sha256sum_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/9/isos/x86_64/CHECKSUM"
}

source "qemu" "alma9" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/alma.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = var.headless
  http_directory   = "http"
  iso_checksum     = "file:${var.alma_sha256sum_url}"
  iso_url          = "${var.alma_iso_url}"
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.alma9"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=alma9",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
