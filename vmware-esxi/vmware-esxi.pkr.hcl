packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "vmware_esxi_iso_path" {
  type    = string
  default = "${env("VMWARE_ESXI_ISO_PATH")}"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}

source "qemu" "esxi" {
  boot_command     = ["<enter><wait>", "<leftShift>O", " ks=cdrom:/KS.CFG", " cpuUniformityHardCheckPanic=FALSE", "systemMediaSize=min", " com1_Port=0x3f8 tty2Port=com1", "<enter>"]
  boot_wait        = "3s"
  cd_files         = ["./KS.CFG"]
  cd_label         = "kickstart"
  communicator     = "none"
  disk_interface   = "ide"
  disk_size        = "32G"
  format           = "raw"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.vmware_esxi_iso_path
  memory           = 8192
  net_device       = "vmxnet3"
  qemuargs         = [["-cpu", "host"], ["-smp", "2,sockets=2,cores=1,threads=1"], ["-serial", "stdio"], ["-enable-kvm"]]
  shutdown_timeout = var.timeout
}

build {
  sources = ["source.qemu.esxi"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=esxi",
      "IMG_FMT=raw",
      "source ../scripts/fuse-nbd",
      "source ./post.sh",
      ]
    inline_shebang = "/bin/bash -e"
  }
  post-processor "compress" {
    output = "vmware-esxi.dd.gz"
  }
}
