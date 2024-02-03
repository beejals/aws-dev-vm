variable "env" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Valid values for var: env are (dev, staging, prod)."
  }
}

variable "host_os" {
  type        = string
  default     = "windows"
  description = "use windows or linux depending on what OS you are running on"

  validation {
    condition     = contains(["windows", "linux"], var.host_os)
    error_message = "Valid values for var: host_os are (windows, linux)."
  }
}

variable "identityfile_name" {
  type    = string
  default = "dev_vm"
}

variable "vpc_cidr_block" {
  type = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "Must be valid IPv4 CIDR block addresses"
  }
}

variable "public_subnet_cidr_block" {
  type = list(string)

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidr_block : can(cidrnetmask(cidr))
    ])
    #condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "All elements Must be valid IPv4 CIDR block addresses"
  }
}

variable "private_subnet_cidr_block" {
  type = list(string)

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidr_block : can(cidrnetmask(cidr))
    ])
    #condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "All elements Must be valid IPv4 CIDR block addresses"
  }
}

variable "availability_zone" {
  type = list(string)
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "github_token" {}