packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "rhel8_iso_path" {
  type    = string
  default = "${env("RHEL8_ISO_PATH")}"
}

source "qemu" "rhel8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel8.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = var.rhel8_iso_path
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.rhel8"]

  post-processor "shell-local" {
    inline         = ["SOURCE=rhel8","source ../scripts/setup-nbd", "OUTPUT=$${OUTPUT:-rhel8.tar.gz}", "source ../scripts/tar-root"]
    inline_shebang = "/bin/bash -e"
  }
}
