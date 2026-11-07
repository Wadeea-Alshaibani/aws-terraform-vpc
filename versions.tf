terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }

  # Remote state in S3 with native locking (Terraform 1.10+).
  # Create the bucket first with ./bootstrap, then:
  #   cp backend.hcl.example backend.hcl   (edit the bucket name)
  #   terraform init -backend-config=backend.hcl
  backend "s3" {}
}
