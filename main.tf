data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  region = "eu-west-1"
  azs    = slice(data.aws_availability_zones.available.names, 0, var.aws_availability_zones_count)

}

################################################################################
# VPC Configuration
# Requirements fulfilled:
# ✅ Minimum 2 AZs: Using slice() to get exactly the number specified in variables
# ✅ Minimum 4 subnets: Creates 2 private + 2 public subnets
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr

  azs = local.azs
  # Private subnets: 10.0.0.0/20, 10.0.16.0/20 (larger for more IPs)
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  # Public subnets: 10.0.48.0/24, 10.0.49.0/24 (smaller for load balancers)
  public_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  # NAT Gateway for private subnet internet access (node group downloads)
  # Cost optimization: Single NAT Gateway saves ~$45/month vs one per AZ
  enable_nat_gateway = true
  single_nat_gateway = true

  # EKS-specific subnet tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = "${var.name}-eks"
  kubernetes_version = var.kubernetes_version

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # API server accessible from public internet (can be restricted later)
  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # Cost-optimized managed node groups
  eks_managed_node_groups = {
    main = {
      # Instance configuration
      instance_types = ["t3.micro"]

      # Scaling configuration - minimal for cost savings
      min_size     = 1
      max_size     = 10
      desired_size = 10
      # Use On-Demand for predictable costs (Spot can be terminated)
      capacity_type = "ON_DEMAND"

      # Network configuration
      subnet_ids = module.vpc.private_subnets

      tags = {
        Environment = "checkpoint-task"
        Terraform   = "true"
      }
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

}

################################################################################
# ECR Repository Configuration
################################################################################

resource "aws_ecr_repository" "main" {
  name                 = "${var.name}/${var.ecr_repository_name}"
  image_tag_mutability = "MUTABLE"


  # Enable image scanning for security
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "checkpoint-task"
    Terraform   = "true"
  }
}

# ECR Repository Policy - Allow EKS to pull images
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSPull"
        Effect = "Allow"
        Principal = {
          AWS = [
            module.eks.cluster_iam_role_arn,
            module.eks.eks_managed_node_groups["main"].iam_role_arn
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
      }
    ]
  })
}

################################################################################
# IAM Role Policy Attachment for EKS Node Group ECR Access
# Ensures EKS nodes can pull from ECR
################################################################################

# Attach ECR read-only policy to EKS node group role
resource "aws_iam_role_policy_attachment" "eks_node_group_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = module.eks.eks_managed_node_groups["main"].iam_role_name
}
