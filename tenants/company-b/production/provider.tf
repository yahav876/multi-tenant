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

# Configure the Helm Provider
provider "helm" {
  kubernetes = {
    host                   = module.eks_auto_mode.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_auto_mode.cluster_certificate_authority_data)
    
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_auto_mode.cluster_name, "--region", var.aws_region]
    }
  }
}

# Configure the kubectl Provider
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks_auto_mode.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_auto_mode.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_auto_mode.cluster_name, "--region", var.aws_region]
  }
}

