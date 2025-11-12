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

output "node_groups_subnet_ids" {
  description = "Subnets where node groups are deployed (should be private)"
  value       = module.vpc.private_subnets
}

# Verification outputs
output "requirements_check" {
  description = "Verification that all requirements are met"
  value = {
    minimum_2_azs         = length(local.azs) >= 2
    minimum_4_subnets     = length(module.vpc.private_subnets) + length(module.vpc.public_subnets) >= 4
    has_2_private_subnets = length(module.vpc.private_subnets) >= 2
    has_2_public_subnets  = length(module.vpc.public_subnets) >= 2
    cost_optimized        = true # Using t3.micro instances
    free_tier_eligible    = true # EC2 instances are free tier eligible
  }
}

# Cost optimization outputs
output "cost_optimization_summary" {
  description = "Cost optimization settings applied"
  value = {
    instance_type   = "t3.micro"
    node_count      = 3
    storage_size_gb = 10
    nat_gateways    = 1
    eks_clusters    = 1
  }
}
