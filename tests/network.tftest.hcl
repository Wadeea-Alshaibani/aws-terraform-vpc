# Runs offline with a mocked AWS provider: no credentials and no cost.
#   terraform init -backend=false && terraform test

mock_provider "aws" {
  override_data {
    target = data.aws_availability_zones.available
    values = { names = ["us-east-1a", "us-east-1b", "us-east-1c"] }
  }
  override_data {
    target = module.web.data.aws_ssm_parameter.al2023
    values = { value = "ami-0123456789abcdef0" }
  }
}

variables {
  owner = "ci-test"
}

# ---------- Whole stack ----------

run "stack_spans_two_azs_by_default" {
  command = plan

  assert {
    condition     = length(module.vpc.public_subnet_ids) == 2 && length(module.vpc.private_subnet_ids) == 2
    error_message = "Expected 2 public and 2 private subnets."
  }
}

run "three_azs_when_requested" {
  command = plan

  variables {
    az_count = 3
  }

  assert {
    condition     = length(module.vpc.private_subnet_ids) == 3
    error_message = "az_count = 3 should create 3 private subnets."
  }
}

run "rejects_non_16_cidr" {
  command = plan

  variables {
    vpc_cidr = "10.10.0.0/24"
  }

  expect_failures = [var.vpc_cidr]
}

# ---------- VPC module ----------

run "vpc_subnet_plan" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  variables {
    name       = "test"
    cidr_block = "10.10.0.0/16"
    azs        = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = [for s in aws_subnet.public : s.cidr_block] == ["10.10.0.0/24", "10.10.1.0/24"]
    error_message = "Public subnets should be 10.10.0.0/24 and 10.10.1.0/24."
  }
  assert {
    condition     = [for s in aws_subnet.private : s.cidr_block] == ["10.10.10.0/24", "10.10.11.0/24"]
    error_message = "Private subnets should be 10.10.10.0/24 and 10.10.11.0/24."
  }
  assert {
    condition     = alltrue([for s in aws_subnet.private : s.map_public_ip_on_launch != true])
    error_message = "Private subnets must not assign public IPs."
  }
  assert {
    condition     = one(aws_route_table.public.route).cidr_block == "0.0.0.0/0"
    error_message = "Public route table needs a default route to the internet gateway."
  }
}

# ---------- Web module ----------

run "web_tier_is_hardened" {
  command = plan

  module {
    source = "./modules/web"
  }

  variables {
    name               = "test"
    vpc_id             = "vpc-0123456789abcdef0"
    public_subnet_ids  = ["subnet-aaa", "subnet-bbb"]
    private_subnet_ids = ["subnet-ccc", "subnet-ddd"]
    allowed_cidrs      = ["203.0.113.10/32"]
    instance_type      = "t3.micro"
    min_size           = 2
    max_size           = 4
  }

  assert {
    condition     = aws_launch_template.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required on web instances."
  }
  assert {
    condition     = aws_lb.this.drop_invalid_header_fields
    error_message = "ALB must drop invalid HTTP headers."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.alb_http["203.0.113.10/32"].from_port == 80
    error_message = "ALB should accept HTTP only from allowed_cidrs."
  }
  assert {
    condition     = aws_autoscaling_group.web.health_check_type == "ELB"
    error_message = "ASG should replace instances that fail load balancer health checks."
  }
}
