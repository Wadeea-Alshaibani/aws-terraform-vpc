variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the web instances"
  type        = list(string)
}

variable "allowed_cidrs" {
  description = "Source CIDRs allowed to reach the ALB on port 80"
  type        = list(string)
}

variable "instance_type" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}
