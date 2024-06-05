packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "headless" {
  type        = bool
  default     = false
  description = "Whether VNC viewer should not be launched."
}

variable "iso_path" {
  type    = string
  default = ""
}

variable "ovmf_suffix" {
  type    = string
  default = "_4M"
}

variable "filename" {
  type        = string
  default     = "windows.dd.gz"
  description = "The filename of the tarball to produce"
}

source "qemu" "windows_builder" {
  accelerator      = "kvm"
  boot_command     = ["<enter>"]
  boot_wait        = "1s"
  communicator     = "none"
  disk_interface   = "ide"
  disk_size        = "20G"
  floppy_files     = ["./http/Autounattend.xml", "./http/logon.ps1", "./http/rh.cer"]
  floppy_label     = "flop"
  format           = "raw"
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = "${var.iso_path}"
  machine_type     = "q35"
  memory           = "4096"
  cpus             = "2"
  net_device       = "e1000"
  qemuargs         = [
    ["-serial", "stdio"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/OVMF/OVMF_CODE${var.ovmf_suffix}.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=OVMF_VARS.fd"],
    ["-drive", "file=output-windows_builder/packer-windows_builder,format=raw"],
    ["-cdrom", "${var.iso_path}"],
    ["-drive", "file=drivers.iso,media=cdrom,index=3"],
    ["-boot", "d"]
  ]
  shutdown_timeout = "45m"
  vnc_bind_address = "0.0.0.0"
}

build {
  sources = ["source.qemu.windows_builder"]

  post-processor "shell-local" {
    inline = [
      "echo 'Syncing output-windows_builder/packer-windows_builder...'",
      "sync -f output-windows_builder/packer-windows_builder",
      "IMG_FMT=raw",
      "source scripts/setup-nbd",
      "TMP_DIR=$(mktemp -d /tmp/packer-maas-XXXX)",
      "echo 'Adding curtin-hooks to image...'",
      "mount -t ntfs $${nbd}p3 $TMP_DIR",
      "mkdir -p $TMP_DIR/curtin",
      "cp ./curtin/* $TMP_DIR/curtin/",
      "sync -f $TMP_DIR/curtin",
      "umount $TMP_DIR",
      "qemu-nbd -d $nbd",
      "rmdir $TMP_DIR"
    ]
    inline_shebang = "/bin/bash -e"
  }
  post-processor "compress" {
    output = "${var.filename}"
  }
}
