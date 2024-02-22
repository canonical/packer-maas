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
  default     = "centos6.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos6_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/CentOS-6.10-x86_64-netinstall.iso"
}

variable "centos6_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/sha256sum.txt"
}

# use can use "--url" to specify the exact url for os repo
variable "ks_os_repos" {
  type    = string
  default = "--url='http://mirror.centos.org/centos/6/os/x86_64'"
}

# Use --baseurl to specify the exact url for updates repo
variable "ks_updates_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=updates'"
}

# Use --baseurl to specify the exact url for extras repo
variable "ks_extras_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=extras'"
}

# Use --baseurl to specify the exact url for EPEL6 repo
variable "ks_epel6_repos" {
  type    = string
  default = "--mirrorlist='https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=x86_64'"
}

# Use --baseurl to specify the exact url for EPEL6 repo
variable "ks_cloudinit_repos" {
  type    = string
  default = "--baseurl='http://copr-be.cloud.fedoraproject.org/results/@cloud-init/el-stable/epel-6-x86_64'"
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
  ks_proxy         = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
  ks_os_repos      = var.ks_mirror != "" ? "--url=${var.ks_mirror}/os/x86_64" : var.ks_os_repos
  ks_updates_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/updates/x86_64" : var.ks_updates_repos
  ks_extras_repos  = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/extras/x86_64" : var.ks_extras_repos
}

source "qemu" "centos6" {
  boot_command     = ["<tab> ", "ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "file:${var.centos6_sha256sum_url}"
  iso_url          = var.centos6_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
  http_content = {
    "/centos6.ks" = templatefile("${path.root}/http/centos6.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_OS_REPOS        = local.ks_os_repos,
        KS_UPDATES_REPOS   = local.ks_updates_repos,
        KS_EXTRAS_REPOS    = local.ks_extras_repos
        KS_EPEL6_REPOS     = var.ks_epel6_repos
        KS_CLOUDINIT_REPOS = var.ks_cloudinit_repos
      }
    )
  }

}

build {
  sources = ["source.qemu.centos6"]

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
