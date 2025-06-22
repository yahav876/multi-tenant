# Company B - Production Environment
# This file contains the main infrastructure configuration for Company B's production environment

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

# module "gke_cluster" {
#   source = "../../../modules/gke-cluster"
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
