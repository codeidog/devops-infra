# DevOps Infrastructure

Terraform configuration for AWS EKS cluster and supporting resources.

## Components

- EKS cluster with managed node groups
- VPC with public/private subnets
- ECR repository for container images
- Nginx ingress controller
- Cluster autoscaler

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

### GitHub Actions Workflows

This repository includes automated workflows for infrastructure management:

- **Terraform Format**: Checks code formatting with `terraform fmt`
- **Terraform Validate**: Validates configuration syntax and consistency
- **Terraform Plan**: Validates and plans infrastructure changes on PRs
- **Terraform Apply**: Deploys infrastructure changes on merge to main

## Access

```bash
aws eks update-kubeconfig --region eu-west-1 --name checkpoint-task-cluster
kubectl get nodes
```
