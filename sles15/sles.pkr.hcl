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
  default     = "sles15.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "sles15_iso_path" {
  type    = string
  default = "${env("SLES15_ISO_PATH")}"
}

source "qemu" "sles15" {
  boot_command     = ["<esc><enter><wait>", "linux netdevice=eth0 netsetup=dhcp install=cd:/<wait>", " lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles15.xml<wait>", " textmode=1<wait>", "<enter><wait>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = var.sles15_iso_path
  memory           = 4096
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.sles15"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=sles15",
      "source ../scripts/setup-nbd",
      "ROOT_PARTITION=p2",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
