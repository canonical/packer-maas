locals {
  qemu_arch = {
    "amd64" = "x86_64"
    "arm64" = "aarch64"
  }
  qemu_machine = {
    "amd64" = "accel=kvm"
    "arm64" = var.host_is_arm ? "virt,accel=kvm" : "virt"
  }
  qemu_cpu = {
    "amd64" = "host"
    "arm64" = var.host_is_arm ? "host" : "max"
  }
  iso_checksum = {
    "amd64" = "file:http://releases.ubuntu.com/${var.ubuntu_series}/SHA256SUMS"
    "arm64" = "file:https://cdimage.ubuntu.com/releases/${var.ubuntu_series}/release/SHA256SUMS"
  }
  iso_url = {
    "amd64" = "https://releases.ubuntu.com/${var.ubuntu_series}/${var.ubuntu_iso}"
    "arm64" = "https://cdimage.ubuntu.com/releases/${var.ubuntu_series}/release/${var.ubuntu_iso}"
  }


  proxy_env = [
    "http_proxy=${var.http_proxy}",
    "https_proxy=${var.https_proxy}",
    "no_proxy=${var.https_proxy}",
  ]
}

source "null" "dependencies" {
  communicator = "none"
}

source "qemu" "cloudimg" {
  boot_wait      = "10s"
  cpus           = 2
  disk_image     = true
  disk_size      = "8G"
  format         = "qcow2"
  headless       = var.headless
  http_directory = var.http_directory
  iso_checksum   = "file:https://cloud-images.ubuntu.com/${var.ubuntu_series}/current/SHA256SUMS"
  iso_url        = "https://cloud-images.ubuntu.com/${var.ubuntu_series}/current/${var.ubuntu_series}-server-cloudimg-${var.architecture}.img"
  memory         = 2048
  qemu_binary    = "qemu-system-${lookup(local.qemu_arch, var.architecture, "")}"
  qemu_img_args {
    create = ["-F", "qcow2"]
  }
  vnc_bind_address = "0.0.0.0"
  qemuargs = [
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-gpu-pci"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=OVMF_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=OVMF_VARS.fd"],
    ["-drive", "file=output-cloudimg/packer-cloudimg,format=qcow2"],
    ["-drive", "file=seeds-cloudimg.iso,format=raw"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = var.timeout
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = var.timeout
  use_backing_file       = true
}

build {
  name    = "cloudimg.deps"
  sources = ["source.null.dependencies"]

  provisioner "shell-local" {
    inline = [
      "cloud-localds seeds-cloudimg.iso user-data-cloudimg meta-data"
    ]
    inline_shebang = "/bin/bash -e"
  }
}

build {
  name    = "cloudimg.image"
  sources = ["source.qemu.cloudimg"]

  provisioner "shell" {
    environment_vars = concat(local.proxy_env, ["DEBIAN_FRONTEND=noninteractive"])
    scripts          = ["${path.root}/scripts/cloudimg/setup-boot.sh"]
  }


  provisioner "shell" {
    environment_vars  = concat(local.proxy_env, ["DEBIAN_FRONTEND=noninteractive"])
    expect_disconnect = true
    scripts           = [var.customize_script]
  }

  provisioner "shell" {
    environment_vars = [
      "CLOUDIMG_CUSTOM_KERNEL=${var.kernel}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    scripts = ["${path.root}/scripts/cloudimg/install-custom-kernel.sh"]
  }

  provisioner "file" {
    destination = "/tmp/"
    sources     = ["${path.root}/scripts/cloudimg/curtin-hooks"]
  }

  provisioner "shell" {
    environment_vars = ["CLOUDIMG_CUSTOM_KERNEL=${var.kernel}"]
    scripts          = ["${path.root}/scripts/cloudimg/setup-curtin.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    scripts          = ["${path.root}/scripts/cloudimg/cleanup.sh"]
  }

  post-processor "shell-local" {
    inline = [
      "IMG_FMT=qcow2",
      "SOURCE=cloudimg",
      "ROOT_PARTITION=1",
      "DETECT_BLS_BOOT=1",
      "OUTPUT=${var.filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
