variable "flat_filename" {
  type        = string
  default     = "custom-ubuntu.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "ubuntu_iso" {
  type        = string
  default     = "ubuntu-22.04.3-live-server-amd64.iso"
  description = "The ISO name to build the image from"
}

