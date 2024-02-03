packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "filename" {
  type        = string
  default     = "centos7.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "centos7_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso"
}

variable "centos7_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/7/isos/x86_64/sha256sum.txt"
}

# use can use "--url" to specify the exact url for os repo
# for ex. "--url='https://archive.kernel.org/centos-vault/7.9.2009/os/x86_64'"
variable "ks_os_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os'"
}

# Use --baseurl to specify the exact url for updates repo
# for ex. "--baseurl='https://archive.kernel.org/centos-vault/7.9.2009/updates/x86_64'"
variable "ks_updates_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates'"
}

# Use --baseurl to specify the exact url for extras repo
# for ex. "--baseurl='https://archive.kernel.org/centos-vault/7.9.2009/extras/x86_64'"
variable "ks_extras_repos" {
  type    = string
  default = "--mirrorlist='http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=extras'"
}

variable ks_proxy {
  type    = string
  default = "${env("KS_PROXY")}"
}

variable ks_mirror {
  type    = string
  default = "${env("KS_MIRROR")}"
}

variable enable_ssh_provisioning {
  type    = bool
  default = false
}

variable enable_ansible_provisioning {
  type    = bool
  default = false
}

variable ssh_username {
  type    = string
  default = "packer"
}

variable ssh_password {
  type    = string
  default = "packer"
}

variable ssh_user_cleanup {
  type    = bool
  default = true
}

locals {
  ks_proxy         = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
  ks_os_repos      = var.ks_mirror != "" ? "--url=${var.ks_mirror}/os/x86_64" : var.ks_os_repos
  ks_updates_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/updates/x86_64" : var.ks_updates_repos
  ks_extras_repos  = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/extras/x86_64" : var.ks_extras_repos
  communicator     = var.enable_ssh_provisioning == true ? "ssh" : "none"
}

source "qemu" "centos7" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos7.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = local.communicator
  disk_size        = "4G"
  headless         = true
  iso_checksum     = "file:${var.centos7_sha256sum_url}"
  iso_url          = var.centos7_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
  ssh_username     = var.enable_ssh_provisioning == true ? var.ssh_username : null
  ssh_password     = var.enable_ssh_provisioning == true ? var.ssh_password : null
  ssh_timeout      = "30m"
  http_content = {
    "/centos7.ks" = templatefile("${path.root}/http/centos7.ks.pkrtpl.hcl",
      {
        KS_PROXY         = local.ks_proxy,
        KS_OS_REPOS      = local.ks_os_repos,
        KS_UPDATES_REPOS = local.ks_updates_repos,
        KS_EXTRAS_REPOS  = local.ks_extras_repos
        SSH_USERNAME     = var.ssh_username
        SSH_PASSWORD     = var.ssh_password
        communicator     = local.communicator
      }
    )
  }
}

build {
  sources = ["source.qemu.centos7"]

  provisioner "ansible" {
    playbook_file      = "../ansible/playbook.yml"
    skip_version_check = true
    only               = var.enable_ansible_provisioning == true ? ["qemu.centos7"] : [""]
  }

  provisioner "shell" {
    script = "../scripts/ssh_provisioning_cleanup.sh"
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}",
      "SSH_USER_CLEANUP=${var.ssh_user_cleanup}",
    ]
    only = var.enable_ssh_provisioning == true ? ["qemu.centos7"] : [""]
  }

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
