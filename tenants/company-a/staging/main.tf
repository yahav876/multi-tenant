# Company A - Staging Environment
# This file contains the main infrastructure configuration for Company A's staging environment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Example module usage - adjust based on your infrastructure needs
# module "vpc" {
#   source = "../../../modules/vpc"
#   
#   environment = var.environment
#   company     = var.company
#   region      = var.region
# }

# module "eks_cluster" {
#   source = "../../../modules/eks-cluster"
#   
#   cluster_name = "${var.company}-${var.environment}-cluster"
#   vpc_id       = module.vpc.vpc_id
#   subnet_ids   = module.vpc.private_subnet_ids
# }

# module "monitoring_stack" {
#   source = "../../../modules/monitoring-stack"
#   
#   environment = var.environment
#   company     = var.company
# }
