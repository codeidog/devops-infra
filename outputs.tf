# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = local.azs
}

output "availability_zones_count" {
  description = "Number of availability zones"
  value       = length(local.azs)
}

# Subnet Outputs
output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

