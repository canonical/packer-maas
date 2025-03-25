variable "filename" {
  type    = string
  default = "rocky-base.qcow2"
}

# Use the same base source
source "qemu" "rocky9" {
  ...
}

build {
  name    = "rocky-cpu"
  sources = ["source.qemu.rocky9"]

  provisioner "file" {
    source      = "local_files/MLNX_OFED_LINUX-*.tgz"
    destination = "/tmp/mofed.tgz"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp",
      "tar -xzf mofed.tgz",
      "cd MLNX_OFED_LINUX-*",
      "./mlnxofedinstall --without-dkms --force",
      "cd /",
      "rm -rf /tmp/MLNX_OFED_LINUX-* /tmp/mofed.tgz"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "mv output-rocky9/packer-rocky9 rocky-cpu.qcow2"
    ]
  }
}

build {
  name    = "rocky-gpu"
  sources = ["source.qemu.rocky9"]

  provisioner "file" {
    source      = "local_files/MLNX_OFED_LINUX-*.tgz"
    destination = "/tmp/mofed.tgz"
  }

  provisioner "file" {
    source      = "local_files/NVIDIA-Linux-*.run"
    destination = "/tmp/nvidia.run"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp",
      "tar -xzf mofed.tgz",
      "cd MLNX_OFED_LINUX-*",
      "./mlnxofedinstall --without-dkms --force",
      "cd /",
      "rm -rf /tmp/MLNX_OFED_LINUX-* /tmp/mofed.tgz"
    ]
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/nvidia.run",
      "/tmp/nvidia.run --silent --no-cc-version-check --disable-nouveau",
      "rm -f /tmp/nvidia.run"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "mv output-rocky9/packer-rocky9 rocky-gpu.qcow2"
    ]
  }
}
