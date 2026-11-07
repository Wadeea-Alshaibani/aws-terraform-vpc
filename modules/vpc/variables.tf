variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block (a /16 is expected by the subnet plan)"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0)) && endswith(var.cidr_block, "/16")
    error_message = "cidr_block must be a valid /16, for example 10.10.0.0/16."
  }
}

variable "azs" {
  description = "Availability Zones to use (at least 2 for high availability)"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Use at least 2 Availability Zones."
  }
}
