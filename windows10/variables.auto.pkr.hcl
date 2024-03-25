packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.0"
    }
  }
}

variable "autounattend" {
  type    = string
  default = "./http/Autounattend.xml"
}

variable "iso_url" {
  type    = string
}

variable "virtio_win_iso" {
  type    = string
}

variable "iso_checksum" {
  type    = string
}

variable "cpus" {
  type    = string
  default = "4"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vm_name" {
  type    = string
  default = "windows_10"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}