packer {
  required_version = ">= 1.11.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "filename" {
  type        = string
  default     = "rocky9.tar.gz"
  description = "The filename of the tarball to produce"
}

variable ks_proxy {
  type    = string
  default = "${env("KS_PROXY")}"
}

variable ks_mirror {
  type    = string
  default = "${env("KS_MIRROR")}"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "host_is_arm" {
  type        = bool
  default     = false
  description = "The host architecture is aarch64"
}

variable "ovmf_suffix" {
  type        = string
  default     = ""
  description = "Suffix for OVMF CODE and VARS files. Newer systems such as Noble use _4M."
}

locals {
  qemu_arch = {
    "x86_64"  = "x86_64"
    "aarch64" = "aarch64"
  }
  uefi_imp = {
    "x86_64"  = "OVMF"
    "aarch64" = "AAVMF"
  }
  uefi_sfx = {
    "x86_64"  = "${var.ovmf_suffix}"
    "aarch64" = ""
  }
  qemu_machine = {
    "x86_64"  = "accel=kvm"
    "aarch64" = var.host_is_arm ? "virt,accel=kvm" : "virt"
  }
  qemu_cpu = {
    "x86_64"  = "host"
    "aarch64" = var.host_is_arm ? "host" : "max"
  }

  ks_proxy           = var.ks_proxy != "" ? "--proxy=${var.ks_proxy}" : ""
  ks_os_repos        = var.ks_mirror != "" ? "--url=${var.ks_mirror}/BaseOS/${var.architecture}/os" : "--mirrorlist='http://mirrors.rockylinux.org/mirrorlist?arch=${var.architecture}&repo=BaseOS-9.4'"
  ks_appstream_repos = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/AppStream/${var.architecture}/os" : "--mirrorlist='https://mirrors.rockylinux.org/mirrorlist?release=9&arch=${var.architecture}&repo=AppStream-9.4'"
  ks_extras_repos    = var.ks_mirror != "" ? "--baseurl=${var.ks_mirror}/extras/${var.architecture}/os" : "--mirrorlist='https://mirrors.rockylinux.org/mirrorlist?arch=${var.architecture}&repo=extras-9.4'"
}

source "qemu" "rocky9" {
  boot_command     = ["<up><wait>", "e", "<down><down><down><left>", " console=ttyS0 inst.cmdline inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky9.ks <f10>"]
  boot_wait        = "5s"
  communicator     = "ssh"
  ssh_username     = "root"
  ssh_password     = "password"
  ssh_timeout      = "60m"
  disk_size        = "45G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "file:https://dl.rockylinux.org/vault/rocky/9.4/isos/${var.architecture}/Rocky-9.4-${var.architecture}-boot.iso.CHECKSUM"
  iso_url          = "https://dl.rockylinux.org/vault/rocky/9.4/isos/${var.architecture}/Rocky-9.4-${var.architecture}-boot.iso"
  iso_target_path  = "packer_cache/Rocky-${var.architecture}-boot.iso"
  memory           = 2048
  cores            = 4
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"
  qemuargs = [
    ["-device", "virtio-rng-pci"],
    ["-boot", "order=c"],
    ["-serial", "stdio"],
    ["-boot", "strict=off"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    [ "-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:22,id=forward"],
    [ "-device", "virtio-net,netdev=forward,id=net0"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-gpu-pci"],
    ["-global", "driver=cfi.pflash01,property=secure,value=off"],
    ["-drive", "if=pflash,format=raw,unit=0,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE${lookup(local.uefi_sfx, var.architecture, "")}.fd"],
    ["-drive", "if=pflash,format=raw,unit=1,id=ovmf_vars,file=${var.architecture}_VARS.fd"],
    ["-drive", "file=output-rocky9/packer-rocky9,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=packer_cache/Rocky-${var.architecture}-boot.iso,if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_timeout = var.timeout
  http_content = {
    "/rocky9.ks" = templatefile("${path.root}/http/rocky9.ks.pkrtpl.hcl",
      {
        KS_PROXY           = local.ks_proxy,
        KS_OS_REPOS        = local.ks_os_repos,
        KS_APPSTREAM_REPOS = local.ks_appstream_repos,
        KS_EXTRAS_REPOS    = local.ks_extras_repos
      }
    )
  }
}

build {
  sources = ["source.qemu.rocky9"]

  provisioner "shell" {
    script = "./post-install.sh"
    # Ensure the script is executable and run it with sudo
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  }
}
