packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "ssh_password" {
  type    = string
  default = "secret"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "headless" {
  type        = bool
  default     = false
  description = "Whether VNC viewer should not be launched."
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "filename" {
  type        = string
  default     = "sles12.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "sles12_iso_path" {
  type    = string
  default = "${env("SLES12_ISO_PATH")}"
}

locals {
  qemu_arch    = "x86_64"
  uefi_imp     = "OVMF"
  qemu_machine = "ubuntu,accel=kvm"
  qemu_cpu     = "host"
  proxy_env = [
    "http_proxy=${var.http_proxy}",
    "https_proxy=${var.https_proxy}",
    "no_proxy=${var.https_proxy}",
  ]
}

source "null" "dependencies" {
  communicator = "none"
}

source "qemu" "sles12" {
  boot_wait      = "2s"
  cpus           = 2
  disk_image     = true
  disk_size      = "4G"
  format         = "qcow2"
  headless       = var.headless
  http_directory = var.http_directory
  iso_checksum   = "none"
  iso_url        = var.sles12_iso_path
  memory         = 2048
  qemu_binary    = "qemu-system-${local.qemu_arch}"
  qemu_img_args {
    create = ["-F", "qcow2"]
  }
  qemuargs = [
    ["-machine", "${local.qemu_machine}"],
    ["-cpu", "${local.qemu_cpu}"],
    ["-device", "virtio-gpu-pci"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/${local.uefi_imp}/${local.uefi_imp}_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=${local.uefi_imp}_VARS.fd"],
    ["-drive", "file=output-sles12/packer-sles12,format=qcow2"],
    ["-drive", "file=seeds-cloudimg.iso,format=raw"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "45m"
  use_backing_file       = true
}

build {
  name    = "sles.deps"
  sources = ["source.null.dependencies"]

  provisioner "shell-local" {
    inline = [
      "cp /usr/share/${local.uefi_imp}/${local.uefi_imp}_VARS.fd ${local.uefi_imp}_VARS.fd",
      "cloud-localds seeds-cloudimg.iso user-data meta-data"
    ]
    inline_shebang = "/bin/bash -e"
  }
}

build {
  name    = "sles.image"
  sources = ["source.qemu.sles12"]

  provisioner "shell" {
    environment_vars = local.proxy_env
    scripts          = ["${path.root}/scripts/cleanup.sh"]
  }

  post-processor "shell-local" {
    inline = [
      "SOURCE=sles12",
      "ROOT_PARTITION=p3",
      "source ../scripts/setup-nbd",
      "OUTPUT=${var.filename}",
      "source ../scripts/tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
