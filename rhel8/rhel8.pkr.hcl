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
  default     = "rhel8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "rhel8_iso_path" {
  type    = string
  default = "${env("RHEL8_ISO_PATH")}"
}

# Use --baseurl to specify the exact url for AppStream repo
variable "ks_appstream_repos" {
  type    = string
  default = "--baseurl='file:///run/install/repo/AppStream'"
}

variable ks_proxy {
  type    = string
  default = "${env("KS_PROXY")}"
}

locals {
  ks_proxy = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
}

source "qemu" "rhel8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel8.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.rhel8_iso_path
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
  http_content = {
    "/rhel8.ks" = templatefile("${path.root}/http/rhel8.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_APPSTREAM_REPOS = var.ks_appstream_repos,
      }
    )
  }

}

build {
  sources = ["source.qemu.rhel8"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=${source.name}",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root",
      "rm -rf output-${source.name}",
    ]
    inline_shebang = "/bin/bash -e"
  }
}
