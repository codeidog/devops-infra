variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}
variable "name" {
  description = "The name prefix for resources"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "aws_availability_zones_count" {
  description = "The number of availability zones to use (minimum 2 required)"
  type        = number
  default     = 2

  validation {
    condition     = var.aws_availability_zones_count >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}
variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository for container images"
  type        = string
  default     = "counter-service"
}
