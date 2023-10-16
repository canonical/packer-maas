packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "virtualbox-iso" "box" {
   boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  boot_wait       = "2s"
  cpus            = 2
  disk_size       = 8192
  guest_os_type   = "Ubuntu_64"
  headless        = var.headless
  http_directory  = var.http_directory
  iso_checksum    = "file:http://releases.ubuntu.com/jammy/SHA256SUMS"
  iso_target_path = "packer_cache/ubuntu.iso"
  iso_url         = "https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
  memory          = 2048
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_ubuntu_password
  ssh_timeout            = "45m"
  ssh_username           = "ubuntu"
  ssh_wait_timeout       = "45m"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--vram", "16"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--add", "ide"],
    ["storageattach", "{{.Name}}", "--storagectl", "IDE Controller", "--port", "0", "--device", "0", "--type", "hdd", "--medium", "output-lvm/packer-lvm.vdi"],
    ["storageattach", "{{.Name}}", "--storagectl", "IDE Controller", "--port", "1", "--device", "0", "--type", "dvddrive", "--medium", "seeds-lvm.iso"],
    ["storageattach", "{{.Name}}", "--storagectl", "IDE Controller", "--port", "2", "--device", "0", "--type", "dvddrive", "--medium", "packer_cache/ubuntu.iso"],
    ["modifyvm", "{{.Name}}", "--firmware", "efi"],
    ["modifyvm", "{{.Name}}", "--boot1", "disk", "--boot2", "dvd"]
  ]
}

build {
  sources = ["source.virtualbox-iso.box"]

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

  post-processor "vagrant" {
    output = "custom-ubuntu-virtual.box"
  }
}