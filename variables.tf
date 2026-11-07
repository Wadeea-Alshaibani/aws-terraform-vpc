variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name, used in resource names and tags"
  type        = string
  default     = "netops"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag, e.g. your name or email"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block (/16)"
  type        = string
  default     = "10.10.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid /16, for example 10.10.0.0/16."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "allowed_cidrs" {
  description = "Who may reach the website. Use [\"<your-public-ip>/32\"] to keep it private."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  description = "Minimum (and starting) number of web instances"
  type        = number
  default     = 2
}

variable "max_size" {
  type    = number
  default = 4
}
