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
  default     = "rhel7.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "rhel7_iso_path" {
  type    = string
  default = "${env("RHEL7_ISO_PATH")}"
}

source "qemu" "rhel7" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel7.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = var.rhel7_iso_path
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.rhel7"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=rhel7",
      "source ../scripts/setup-nbd",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
