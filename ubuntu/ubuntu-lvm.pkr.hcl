source "qemu" "lvm" {
  boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  boot_wait       = "2s"
  cpus            = 2
  disk_size       = "8G"
  format          = "raw"
  headless        = var.headless
  http_directory  = var.http_directory
  iso_checksum    = "file:http://releases.ubuntu.com/${var.ubuntu_series}/SHA256SUMS"
  iso_target_path = "packer_cache/${var.ubuntu_series}.iso"
  iso_url         = "https://releases.ubuntu.com/${var.ubuntu_series}/${var.ubuntu_lvm_iso}"
  memory          = 2048
  qemuargs = [
    ["-vga", "qxl"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-device", "virtio-blk-pci,drive=drive1,bootindex=2"],
    ["-drive", "if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd"],
    ["-drive", "if=pflash,format=raw,file=OVMF_VARS.fd"],
    ["-drive", "file=output-lvm/packer-lvm,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    ["-drive", "file=seeds-lvm.iso,format=raw,cache=none,if=none,id=drive1,readonly=on"],
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
  sources = ["source.qemu.lvm"]

  provisioner "file" {
    destination = "/tmp/curtin-hooks"
    source      = "${path.root}/scripts/curtin-hooks"
  }

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/curtin.sh", "${path.root}/scripts/networking.sh", "${path.root}/scripts/cleanup.sh"]
  }

  post-processor "compress" {
    output = "custom-ubuntu-lvm.dd.gz"
  }
}
