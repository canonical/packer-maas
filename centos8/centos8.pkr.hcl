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
  default     = "centos8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos8_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/8.4.2105/isos/x86_64/CentOS-8.4.2105-x86_64-boot.iso"
}

variable "centos8_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/8.4.2105/isos/x86_64/CHECKSUM"
}

# use can use "--url" to specify the exact url for BaseOS repo
variable "ks_os_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=BaseOS'"
}

# Use --baseurl to specify the exact url for AppStream repo
variable "ks_appstream_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=AppStream'"
}

# Use --baseurl to specify the exact url for extras repo
variable "ks_extras_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=extras'"
}

variable ks_proxy {
  type    = string
  default = "${env("KS_PROXY")}"
}

variable ks_mirror {
  type    = string
  default = "${env("KS_MIRROR")}"
}

locals {
  ks_proxy        = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
  ks_os_repos     = var.ks_mirror != "" ? "--url=${var.ks_mirror}/os/x86_64" : var.ks_os_repos
  ks_extras_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/extras/x86_64" : var.ks_extras_repos
}

source "qemu" "centos8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "file:${var.centos8_sha256sum_url}"
  iso_url          = var.centos8_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
  http_content = {
    "/centos8.ks" = templatefile("${path.root}/http/centos7.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_OS_REPOS        = local.ks_os_repos,
        KS_APPSTREAM_REPOS = var.ks_appstream_repos,
        KS_EXTRAS_REPOS    = local.ks_extras_repos
      }
    )
  }

}

build {
  sources = ["source.qemu.centos8"]

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
