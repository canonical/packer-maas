variable "debian_series" {
  type        = string
  default     = "bullseye"
  description = "The codename of the debian series to build."
}

variable "debian_version" {
  type        = string
  default     = "11"
  description = "The version number of the debian series to build."
}

variable "boot_mode" {
  type        = string
  default     = "uefi"
  description = "The default boot mode support baked into the image."
}

variable "filename" {
  type        = string
  default     = "debian-custom-cloudimg.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "kernel" {
  type        = string
  default     = ""
  description = "The package name of the kernel to install. May include version string, e.g linux-image-amd64=5.10.127-2~bpo10+1"
}

variable "customize_script" {
  type        = string
  default     = "/dev/null"
  description = "The filename of the script that will run in the VM to customize the image."
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "ovmf_suffix" {
  type        = string
  default     = ""
  description = "Suffix for OVMF CODE and VARS files. Newer systems such as Noble use _4M."
}
