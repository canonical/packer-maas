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
  default     = "alma8.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "alma_iso_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8-latest-x86_64-boot.iso"
}

variable "alma_sha256sum_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/8/isos/x86_64/CHECKSUM"
}

# use can use "--url" to specify the exact url for os repo
# for ex. "--url='https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os'"
variable "ks_os_repos" {
  type    = string
  default = "--mirrorlist='https://mirrors.almalinux.org/mirrorlist/8/baseos'"
}

# Use --baseurl to specify the exact url for appstream repo
# for ex. "--baseurl='https://repo.almalinux.org/almalinux/8/AppStream/x86_64/os'"
variable "ks_appstream_repos" {
  type    = string
  default = "--mirrorlist='https://mirrors.almalinux.org/mirrorlist/8/appstream'"
}

# Use --baseurl to specify the exact url for extras repo
# for ex. "--baseurl='https://repo.almalinux.org/almalinux/8/extras/x86_64/os'"
variable "ks_extras_repos" {
  type    = string
  default = "--mirrorlist='https://mirrors.almalinux.org/mirrorlist/8/extras'"
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
  ks_proxy           = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
  ks_os_repos        = var.ks_mirror != "" ? "--url=${var.ks_mirror}/BaseOS/x86_64/os" : var.ks_os_repos
  ks_appstream_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/AppStream/x86_64/os" : var.ks_appstream_repos
  ks_extras_repos    = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/extras/x86_64/os" : var.ks_extras_repos
}

source "qemu" "alma8" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/alma8.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "file:${var.alma_sha256sum_url}"
  iso_url          = var.alma_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
  http_content = {
    "/alma8.ks" = templatefile("${path.root}/http/alma8.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_OS_REPOS        = local.ks_os_repos,
        KS_APPSTREAM_REPOS = local.ks_appstream_repos,
        KS_EXTRAS_REPOS    = local.ks_extras_repos
      }
    )
  }
}

build {
  sources = ["source.qemu.alma8"]

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
