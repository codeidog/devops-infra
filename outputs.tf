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

output "private_subnets_count" {
  description = "Number of private subnets"
  value       = length(module.vpc.private_subnets)
}

output "public_subnets_count" {
  description = "Number of public subnets"
  value       = length(module.vpc.public_subnets)
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_subnet_ids" {
  description = "Subnets used by EKS cluster"
  value       = concat(module.vpc.private_subnets, module.vpc.public_subnets)
}
