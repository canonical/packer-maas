packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.0"
    }
  }
}

variable "architecture" { type = string }
variable "timeout"      { type = string }
variable "ovmf_suffix"  { type = string }
variable "host_is_arm"  { type = bool }
variable "image_type"   { type = string }

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
    "x86_64"  = var.ovmf_suffix
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
}

source "qemu" "rocky9" {
  boot_command     = ["<up><wait>", "e", "<down><down><down><left>", " console=ttyS0 inst.cmdline inst.text inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/rocky9.ks <f10>"]
  boot_wait        = "5s"
  communicator     = "ssh"
  ssh_username     = "rocky"
  ssh_password     = "rocky"
  ssh_timeout      = "60m"
  ssh_wait_timeout = "20m"
  disk_size        = "45G"
  format           = "qcow2"
  headless         = true
  iso_checksum     = "file:https://dl.rockylinux.org/vault/rocky/9.5/isos/${var.architecture}/Rocky-9.5-${var.architecture}-boot.iso.CHECKSUM"
  iso_url          = "https://dl.rockylinux.org/vault/rocky/9.5/isos/${var.architecture}/Rocky-9.5-${var.architecture}-boot.iso"
  iso_target_path  = "packer_cache/Rocky-${var.architecture}-boot.iso"
  memory           = 2048
  cores            = 4
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"

  qemuargs = [
    ["-serial", "stdio"],
    ["-device", "virtio-rng-pci"],
    ["-boot", "order=c"],
    ["-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:22,id=net0"],
    ["-device", "virtio-net,netdev=net0,id=net0"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-device", "virtio-gpu-pci"],
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-global", "driver=cfi.pflash01,property=secure,value=off"],
    ["-drive", "if=pflash,format=raw,unit=0,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE${lookup(local.uefi_sfx, var.architecture, "")}.fd"],
    ["-drive", "if=pflash,format=raw,unit=1,id=ovmf_vars,file=${var.architecture}_VARS.fd"],
    ["-drive", "file=output-rocky9/packer-rocky9,if=none,id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "file=packer_cache/Rocky-${var.architecture}-boot.iso,if=none,id=cdrom0,media=cdrom"]
  ]

  shutdown_timeout = var.timeout

  http_content = {
    "/rocky9.ks" = file("http/rocky9.ks.pkrtpl.hcl")
  }
}

build {
  name    = "rocky-${var.image_type}"
  sources = ["source.qemu.rocky9"]

  # Always run DOCA post-install script
  provisioner "shell" {
    script = "./post-install-doca.sh"
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  }

  # Conditionally run GPU post-install script if image_type is gpu
  provisioner "shell" {
    script = "./post-install-gpu.sh"
    execute_command = "if [ \"${var.image_type}\" = \"gpu\" ]; then chmod +x {{ .Path }} && {{ .Vars }} sudo -E sh '{{ .Path }}'; else echo 'Skipping GPU script'; fi"
  }

  post-processor "shell-local" {
    inline = ["mv output-rocky9/packer-rocky9 rocky-${var.image_type}.qcow2"]
  }
}

