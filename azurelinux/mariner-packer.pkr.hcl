variable "cpu" {
  type    = string
  default = "4"
}

variable "disk_size" {
  type    = string
  default = "4G"
}

variable "iso_checksum" {
  type    = string
  default = "none"
}

variable "iso_url" {
  type    = string
  default = "./Mariner-2.0-x86_64.iso"
}

variable "mariner_config_file" {
  type    = string
  default = "mariner_config.json"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "out_dir" {
  type    = string
  default = "output-azurelinux"
}

variable "ovmf_suffix" {
  type    = string
  default = "_4M"
}

variable "password" {
  type    = string
  default = "mariner"
}

variable "postinstall_script" {
  type    = string
  default = "scripts/postinstall.bash"
}

variable "username" {
  type    = string
  default = "mariner"
}

variable "timeout" {
  type    = string
  default = "1h"
}

variable "filename" {
  type        = string
  default     = "azurelinux.tar.gz"
  description = "The filename of the tarball to produce"
}

source "qemu" "azurelinux" {
  accelerator      = "kvm"
  boot_command = [
        "<esc><wait>",
        "<rightCtrlOn>c<rightCtrlOff><tab><enter><wait>",
        "<left><enter><wait><left><enter>",
        # Bring up QEMU/Packer NIC
        " IFACE=$(ls /sys/class/net | grep -v '^lo$' | head -1)<enter>",
        " mkdir -p /run/systemd/network<enter>",
        " printf '[Match]\\nName=%s\\n\\n[Network]\\nDHCP=yes\\n' \"$IFACE\" > /run/systemd/network/10-packer.network<enter>",
        " systemctl restart systemd-networkd<enter><wait5>",
        " cd /root <enter><wait>",
        " mkdir -p $HOME/config/scripts <enter><wait>",
        " curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.mariner_config_file} -o $HOME/${var.mariner_config_file} <enter><wait>",
        " sed -i 's#@POSTINSTALLSCRIPT@#${var.postinstall_script}#g;s/@USERNAME@/${var.username}/g;s/@PASSWORD@/${var.password}/g' $HOME/${var.mariner_config_file} <enter><wait>",
        " curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/packages.json -o $HOME/config/packages.json <enter><wait>",
        " cp -R /mnt/cdrom/config/* $HOME/config <enter><wait>",
        " curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.postinstall_script} -o $HOME/config/${var.postinstall_script} <enter><wait>",
        " chmod 755 $HOME/config/${var.postinstall_script} <enter><wait>",
        " $HOME/runliveinstaller -u $HOME/${var.mariner_config_file} -c $HOME/config <enter><wait>",
        " <wait3m>"
  ]
  boot_wait        = "40s"
  communicator     = "none"
  cpus             = "${var.cpu}"
  disk_interface   = "virtio"
  disk_size        = "${var.disk_size}"
  format           = "qcow2"
  headless         = true
  http_directory   = "./http/"
  http_port_max    = "8500"
  http_port_min    = "8000"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "${var.out_dir}"
  qemuargs         = [
        ["-machine", "ubuntu,accel=kvm"],
        ["-boot", "strict=off"],
        ["-cpu", "host"],
        ["-device", "qemu-xhci"],
        ["-device", "usb-kbd"],
        ["-device", "virtio-net-pci,netdev=net0"],
        ["-netdev", "user,id=net0"],
        ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/OVMF/OVMF_CODE${var.ovmf_suffix}.fd"],
        ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=OVMF_VARS.fd"],
        ["-drive", "file=${var.out_dir}/packer-azurelinux,format=qcow2"],
        ["-cdrom", "${var.iso_url}" ],
        ["-serial", "stdio"],
  ]
}

build {
  sources = ["source.qemu.azurelinux"]

  provisioner "shell-local" {
    inline = [ "kill -9 $(ps aux | grep -w packer-azurelinux | grep qemu | awk '{print $2}')" ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "shell-local" {
    inline = [
      "IMG_FMT=qcow2",
      "SOURCE=azurelinux",
      "ROOT_PARTITION=2",
      "DETECT_BLS_BOOT=1",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }

}
