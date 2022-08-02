packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
    }
  }
}

variable "rocky_iso_url" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/8.6/isos/x86_64/Rocky-8.6-x86_64-boot.iso"
}

variable "rocky_sha256sum_url" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/8.6/isos/x86_64/CHECKSUM"
}

source "qemu" "rocky8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.rocky_sha256sum_url}"
  iso_url          = var.rocky_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.rocky8"]

  post-processor "shell-local" {
    inline         = ["source ../scripts/setup-nbd", "OUTPUT=$${OUTPUT:-rocky8.tar.gz}", "source ../scripts/tar-root"]
    inline_shebang = "/bin/bash -e"
  }
}
