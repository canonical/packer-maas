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
  default     = "centos9-stream.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos9_stream_iso_url" {
  type    = string
  default = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
}

variable "centos9_stream_sha256sum_url" {
  type    = string
  default = "none"
}

# use can use "--url" to specify the exact url for os repo
variable "ks_os_repos" {
  type    = string
  default = "--mirrorlist='https://mirrors.centos.org/metalink?repo=centos-baseos-9-stream&arch=x86_64&protocol=https,http'"
}

# use can use "--url" to specify the exact url for baseOS repo
variable "ks_baseos_repos" {
  type    = string
  default = "--metalink='https://mirrors.centos.org/metalink?repo=centos-baseos-9-stream&arch=x86_64&protocol=https,http'"
}

# Use --baseurl to specify the exact url for AppStream repo
variable "ks_appstream_repos" {
  type    = string
  default = "--metalink='https://mirrors.centos.org/metalink?repo=centos-appstream-9-stream&arch=x86_64&protocol=https,http'"
}

# Use --baseurl to specify the exact url for centos repo
variable "ks_centos_repos" {
  type    = string
  default = "--metalink='https://mirrors.centos.org/metalink?repo=centos-crb-9-stream&arch=x86_64&protocol=https,http'"
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
  ks_os_repos        = var.ks_mirror != "" ? "--url=${var.ks_mirror}/BaseOS/x86_64" : var.ks_os_repos
  ks_baseos_repos    = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/BaseOS/x86_64" : var.ks_baseos_repos
  ks_appstream_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/AppStream/x86_64" : var.ks_appstream_repos
  ks_centos_repos    = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/CRB/x86_64" : var.ks_centos_repos
}

source "qemu" "centos9-stream" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos9-stream.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  iso_checksum     = var.centos9_stream_sha256sum_url
  iso_url          = var.centos9_stream_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"], ["-cpu", "host"]]
  shutdown_timeout = "1h"
  http_content = {
    "/centos9-stream.ks" = templatefile("${path.root}/http/centos9-stream.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_OS_REPOS        = local.ks_os_repos,
        KS_BASEOS_REPOS    = local.ks_baseos_repos,
        KS_APPSTREAM_REPOS = local.ks_appstream_repos,
        KS_CENTOS_REPOS    = local.ks_centos_repos
      }
    )
  }

}

build {
  sources = ["source.qemu.centos9-stream"]

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
