provider "aws" {
  region = var.region

  # Tags applied to every resource: helps with cost tracking and cleanup.
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

module "vpc" {
  source = "./modules/vpc"

  name       = local.name
  cidr_block = var.vpc_cidr
  azs        = local.azs
}

module "web" {
  source = "./modules/web"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  allowed_cidrs      = var.allowed_cidrs
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
}
