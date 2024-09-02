source "qemu" "flat" {
  boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  boot_wait       = "2s"
  cpus            = 2
  disk_size       = "8G"
  format          = "raw"
  headless        = var.headless
  http_directory  = var.http_directory
  iso_checksum    = "file:http://releases.ubuntu.com/${var.ubuntu_series}/SHA256SUMS"
  iso_target_path = "packer_cache/${var.ubuntu_series}.iso"
  iso_url         = "https://releases.ubuntu.com/${var.ubuntu_series}/${var.ubuntu_iso}"
  memory          = 2048
  qemuargs = [
    ["-vga", "qxl"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-device", "virtio-blk-pci,drive=drive1,bootindex=2"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE${var.ovmf_suffix}.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=${lookup(local.uefi_imp, var.architecture, "")}_VARS.fd"],
    ["-drive", "file=output-flat/packer-flat,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    ["-drive", "file=seeds-flat.iso,format=raw,cache=none,if=none,id=drive1,readonly=on"],
    ["-drive", "file=packer_cache/${var.ubuntu_series}.iso,if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_ubuntu_password
  ssh_timeout            = var.timeout
  ssh_username           = "ubuntu"
  ssh_wait_timeout       = var.timeout
}

build {
  sources = ["source.qemu.flat"]

  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "${path.root}/scripts/curtin-hooks",
      "${path.root}/scripts/install-custom-packages",
      "${path.root}/scripts/setup-bootloader",
      "${path.root}/packages/custom-packages.tar.gz",
      "${path.root}/zadara"
    ]
  }

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/curtin.sh", "${path.root}/scripts/networking.sh"]
  }

  # provisioner "breakpoint" {
  #   disable = false
  #   note    = "this is a breakpoint"
  # }

  provisioner "ansible" {
    playbook_file = "${path.root}/zadara/install-playbook.yml"
    ansible_env_vars = ["ANSIBLE_CONFIG=ansible.cfg"]
  }

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/cleanup.sh"]
  }

  post-processor "shell-local" {
    inline = [
      "SOURCE=flat",
      "IMG_FMT=raw",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.flat_filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
