locals {
  proxy_env = [
    "http_proxy=${var.http_proxy}",
    "https_proxy=${var.https_proxy}",
    "no_proxy=${var.https_proxy}",
  ]
}

source "qemu" "pve" {
  boot_command   = [
    "<down><down><down><enter>",
    "<down><down><down><enter>",
    "<wait30s>",
    "proxmox-fetch-answer http http://{{ .HTTPIP }}:{{ .HTTPPort }}/answer.toml >/run/automatic-installer-answers <enter>",
    "exit <enter>",
  ]
  boot_wait        = "3s"
  cpus             = 2
  memory           = 2048
  disk_size        = "10G"
  format           = "raw"
  headless         = var.headless
  efi_boot         = true
  efi_firmware_code = "OVMF_CODE.fd"
  efi_firmware_vars = "OVMF_VARS.fd"
  efi_drop_efivars = true
  http_content = {
    "/answer.toml" = templatefile("${path.root}/http/answer.toml.pkrtpl.hcl",
      {
        ssh_password = var.ssh_password
      }
    )
  }
  iso_checksum   = "sha256:d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
  iso_url        = "https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso"
  // qemu_img_args {
  //   create = ["-F", "qcow2"]
  // }
  shutdown_command       = "shutdown -P now"
  ssh_handshake_attempts = 50
  ssh_password           = var.ssh_password
  ssh_timeout            = var.timeout
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = var.timeout
}

build {
  sources = ["source.qemu.pve"]

  provisioner "shell" {
    scripts = ["${path.root}/scripts/configure-repositories.sh"]
  }

  provisioner "shell" {
    environment_vars = concat(local.proxy_env, ["DEBIAN_FRONTEND=noninteractive", "DEBIAN_VERSION=${var.debian_version}", "BOOT_MODE=${var.boot_mode}"])
    scripts          = ["${path.root}/scripts/essential-packages.sh", "${path.root}/scripts/setup-boot.sh", "${path.root}/scripts/networking.sh"]
  }

  provisioner "shell" {
    environment_vars = [
      "CLOUDIMG_CUSTOM_KERNEL=${var.kernel}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    scripts = ["${path.root}/scripts/install-custom-kernel.sh"]
  }

  provisioner "file" {
    destination = "/tmp/"
    sources     = ["${path.root}/scripts/curtin-hooks"]
  }

  provisioner "shell" {
    environment_vars = ["CLOUDIMG_CUSTOM_KERNEL=${var.kernel}"]
    scripts          = ["${path.root}/scripts/setup-curtin.sh"]
  }

  provisioner "file" {
    destination = "/etc/network/"
    sources     = ["${path.root}/files/interfaces"]
  }

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg.d/"
    sources     = ["${path.root}/files/99_eni.cfg"]
  }

  provisioner "file" {
    destination = "/usr/lib/python3/dist-packages/cloudinit/net/network_state.py"
    sources     = ["${path.root}/files/network_state.py"]
  }

  post-processor "compress" {
    output = "pve_lvm.dd.gz"
  }
}
