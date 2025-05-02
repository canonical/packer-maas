packer {
  required_version = ">= 1.12.0"
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
  accelerator      = "kvm"
  boot_command     = ["<enter><wait>", "<leftShift>O", " ks=usb:./KS.CFG", " cpuUniformityHardCheckPanic=FALSE", " systemMediaSize=min", " com1_Port=0x3f8 tty2Port=com1", "<enter>"]
  boot_wait        = "3s"
  communicator     = "none"
  disk_size        = "32G"
  format           = "raw"
  headless         = true
  iso_checksum     = "none"
  iso_url          = var.vmware_esxi_iso_path
  machine_type     = "q35"
  memory           = 8192
  cpus             = "4"
  net_device       = "vmxnet3"
  qemuargs         = [
      ["-cpu", "host"],
      ["-serial", "stdio"],
      ["-usb"],
      ["-device", "usb-storage,drive=usb0"],
      ["-drive", "file=usb.img,if=none,id=usb0,format=raw"],
      ["-cdrom", "${var.vmware_esxi_iso_path}" ],
      ["-device", "ide-hd,drive=ide-disk"],
      ["-drive", "file=output-esxi/packer-esxi,if=none,id=ide-disk,cache=writeback,discard=ignore,format=raw"],
      ["-boot", "d"]
  ]
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
