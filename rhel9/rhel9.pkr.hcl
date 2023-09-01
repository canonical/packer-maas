packer {
  required_version = ">= 1.9.0"
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "filename" {
  type        = string
  default     = "rhel9.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "rhel9_iso_path" {
  type    = string
  default = "${env("RHEL9_ISO_PATH")}"
}

source "qemu" "rhel9" {
  boot_command     = ["<up><tab>", "<spacebar>", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel9.ks", "<spacebar>", "console=ttyS0", "<spacebar>", "inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = var.rhel9_iso_path
  memory           = 4096
  qemuargs         = [["-serial", "stdio"], ["-cpu", "max"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.rhel9"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=rhel9",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
