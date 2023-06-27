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
  memory           = 4096
  net_device       = "vmxnet3"
  qemuargs         = [["-cpu", "host"], ["-smp", "2,sockets=2,cores=1,threads=1"], ["-serial", "stdio"]]
  shutdown_timeout = "1h"
}

build {
  sources = ["source.qemu.esxi"]

  post-processor "shell-local" {
    inline = [
      "SOURCE=esxi",
      "IMG_FMT=raw",
      "source ../scripts/fuse-nbd",
      "echo 'Adding curtin-hooks to image...'",
      "mount_part 1 $TMP_DIR/boot fusefat",
      "cp -rv curtin $TMP_DIR/boot/",
      "sync -f $TMP_DIR/boot",
      "fusermount -u $TMP_DIR/boot",
      "echo 'Adding post-install scripts to image...'",
      "mount_part 6 $TMP_DIR/altbootbank fusefat",
      "cp -rv maas $TMP_DIR/altbootbank/",
      "python3 -m pip install -r requirements.txt --no-compile --target $TMP_DIR/altbootbank",
      "find $TMP_DIR/altbootbank -name __pycache__ -type d -or -name *.so | xargs rm -rf",
      "echo 'Unmounting image...'",
      "sync -f $TMP_DIR/altbootbank",
      "fusermount -u $TMP_DIR/altbootbank",
      ]
    inline_shebang = "/bin/bash -e"
  }
  post-processor "compress" {
    output = "vmware-esxi.dd.gz"
  }
}
