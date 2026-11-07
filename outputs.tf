output "website_url" {
  description = "Open this in a browser (allow 2-3 minutes after apply for instances to boot)"
  value       = "http://${module.web.alb_dns_name}"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_public_ip" {
  value = module.vpc.nat_public_ip
}

output "asg_name" {
  value = module.web.asg_name
}
