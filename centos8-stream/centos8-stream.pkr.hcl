
variable "centos8_stream_iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso"
}

variable "centos8_stream_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/8-stream/isos/x86_64/CHECKSUM"
}

source "qemu" "centos8-stream" {
  boot_command     = ["<up><tab> ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8-stream.ks ", "console=ttyS0 inst.cmdline", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "4G"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.centos8_stream_sha256sum_url}"
  iso_url          = var.centos8_stream_iso_url
  memory           = 2048
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.centos8-stream"]

  post-processor "shell-local" {
    inline         = ["source ../scripts/setup-nbd", "OUTPUT=$${OUTPUT:-centos8-stream.tar.gz}", "source ../scripts/tar-root"]
    inline_shebang = "/bin/bash -e"
  }
}
