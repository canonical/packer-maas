
source "qemu" "win10" {
  accelerator      = "kvm"
  firmware         =  "/usr/share/ovmf/OVMF.fd"
  machine_type     = "q35"
  format           = "raw"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  memory           = "${var.memory}"

  boot_wait        = "-1s"
  boot_command     = ["<wait2s><enter><wait>"]
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  headless         = "${var.headless}"

  communicator     = "winrm"
  winrm_username   = "defaultuser"
  winrm_password   = "defaultpassword"
  winrm_insecure   = true
  winrm_use_ssl    = true
  winrm_timeout    = "${var.winrm_timeout}"
  

  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"

  floppy_files     = [
    "${var.autounattend}",
    "./scripts/fixnetwork.ps1",
    "./scripts/ConfigureRemotingForAnsible.ps1"
  ]
  qemuargs         = [
    ["-drive", "file=output-win10/packer-win10,if=virtio,cache=writeback,discard=ignore,index=1"],
    ["-drive", "file=${var.iso_url},media=cdrom,index=2"],
    ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"]
  ]
}

build {
  sources = ["source.qemu.win10"]
  provisioner "ansible" {
    skip_version_check  = false
    playbook_file = "./ansible/main.yml"
    user = "defaultuser"
    use_proxy = false
    extra_arguments = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore"
    ]
  }

  provisioner "file" {
    source      = "./curtin"
    destination = "C:"
  }

  provisioner "powershell" {
    script = "./scripts/install-cloudbase-init.ps1"
  }

  post-processor "compress" {
    output = "win10.dd.gz"
  }
}
