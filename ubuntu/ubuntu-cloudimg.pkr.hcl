packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "ubuntu_series" {
  type        = string
  default     = "focal"
  description = "The codename of the Ubuntu series to build."
}

variable "filename" {
  type        = string
  default     = "custom-cloudimg.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "kernel" {
  type        = string
  default     = ""
  description = "The package name of the kernel to install. May include version string, e.g linux-image-generic-hwe-22.04=5.15.0.41.43"
}

variable "customize_script" {
  type        = string
  description = "The filename of the script that will run in the VM to customize the image."
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "headless" {
  type        = bool
  default     = true
  description = "Whether VNC viewer should not be launched."
}

variable "http_directory" {
  type        = string
  default     = "http"
  description = "Directory for files to be accessed over http in the VM."
}

variable "http_proxy" {
  type        = string
  default     = "${env("http_proxy")}"
  description = "HTTP proxy to use when customizing the image inside the VM. The http_proxy enviroment is set, and apt is configured to use the http proxy"
}

variable "https_proxy" {
  type        = string
  default     = "${env("https_proxy")}"
  description = "HTTPS proxy to use when customizing the image inside the VM. The https_proxy enviroment is set, and apt is configured to use the https proxy"
}

variable "no_proxy" {
  type        = string
  default     = "${env("no_proxy")}"
  description = "NO_PROXY environment to use when customizing the image inside the VM."
}

variable "ssh_password" {
  type        = string
  default     = "ubuntu"
  description = "SSH password to use to connect to the VM to customize the image. Needs to match the hashed password in user-data-cloudimg."
}

variable "ssh_username" {
  type        = string
  default     = "root"
  description = "SSH user to use to connect to the VM to customize the image. Needs to match the user in user-data-cloudimg."
}

locals {
  qemu_arch = {
    "amd64" = "x86_64"
    "arm64" = "aarch64"
  }
  uefi_imp = {
    "amd64" = "OVMF"
    "arm64" = "AAVMF"
  }
  qemu_machine = {
    "amd64" = "ubuntu,accel=kvm"
    "arm64" = "virt"
  }
  qemu_cpu = {
    "amd64" = "host"
    "arm64" = "cortex-a57"
  }

  proxy_env = [
    "http_proxy=${var.http_proxy}",
    "https_proxy=${var.https_proxy}",
    "no_proxy=${var.https_proxy}",
  ]
}


source "qemu" "cloudimg" {
  boot_wait      = "2s"
  cpus           = 2
  disk_image     = true
  disk_size      = "4G"
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
  qemuargs = [
    ["-machine", "${lookup(local.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(local.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-gpu-pci"],
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.architecture, "")}/${lookup(local.uefi_imp, var.architecture, "")}_VARS.fd"],
    ["-drive", "file=output-qemu/packer-qemu,format=qcow2"],
    ["-drive", "file=seeds-cloudimg.iso,format=raw"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "45m"
  use_backing_file       = true
}

build {
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
      "source ../scripts/setup-nbd",
      "OUTPUT=$${OUTPUT:-${var.filename}}",
      "source ./scripts/cloudimg/tar-rootfs"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
