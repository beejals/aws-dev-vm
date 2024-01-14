variable "host_os" {
  type        = string
  default     = "windows"
  description = "use windows or linux depending on what OS you are running on"

  validation {
    condition     = contains(["windows", "linux"], var.host_os)
    error_message = "Valid values for var: host_os are (windows, linux)."
  }
}

variable "my_ip" {
  type        = string
  description = "Point your browser to https://www.whatismyip.com/ and get the public IPv4 address and provide value as CIDR block e.g. 1.2.3.4/32"

  validation {
    condition     = can(cidrnetmask(var.my_ip))
    error_message = "Must be valid IPv4 CIDR block addresses"
  }
}

variable "identityfile_name" {
  type    = string
  default = "dev_vm"
}