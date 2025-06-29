# AWS Provider Configuration for Company B Production
# This file configures the AWS provider for Company B's production environment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all AWS resources
  default_tags {
    tags = merge(
      var.common_tags,
      {
        Company     = var.company
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )
  }
}

