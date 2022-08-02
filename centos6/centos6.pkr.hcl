
variable "centos6_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/CentOS-6.10-x86_64-netinstall.iso"
}

variable "centos6_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/6.10/isos/x86_64/sha256sum.txt"
}

source "qemu" "centos6" {
  boot_command     = ["<tab> ", "ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.centos6_sha256sum_url}"
  iso_url          = var.centos6_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.centos6"]

  post-processor "shell-local" {
    inline         = ["source ../scripts/setup-nbd", "OUTPUT=$${OUTPUT:-centos6.tar.gz}", "source ../scripts/tar-root"]
    inline_shebang = "/bin/bash -e"
  }
}
