packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "headless" {
  type        = bool
  default     = true
  description = "Whether VNC viewer should not be launched."
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "ssh_password" {
  type    = string
  default = "debian123"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_debian_password" {
  type    = string
  default = "debian"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}

variable "filename" {
  type        = string
  default     = "pve.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "kernel" {
  type        = string
  default     = "proxmox-default-kernel"
  description = "The kernel to use for the image"
}

variable "debian_version" {
  type        = string
  default     = "12"
  description = "The version number of the debian series to build."
}

variable "boot_mode" {
  type        = string
  default     = "uefi"
  description = "The default boot mode support baked into the image."
}