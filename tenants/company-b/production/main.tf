# Company B - Production Environment
# This file contains the main infrastructure configuration for Company B's production environment

# Terraform configuration is defined in provider.tf

# VPC Module - AWS VPC for Company B Production
module "vpc" {
  source = "../../../modules/AWS/Network/vpc"
  
  vpc_name               = var.vpc_name
  vpc_cidr               = var.vpc_cidr
  region                 = var.aws_region
  vpc_azs                = var.vpc_azs
  private_subnet_cidr    = var.private_subnet_cidrs
  public_subnet_cidr     = var.public_subnet_cidrs
  enable_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  
  # Subnet tags for EKS compatibility
  private_subnet_tags = merge(
    var.private_subnet_tags,
    {
      Company     = var.company
      Environment = var.environment
    }
  )
  
  public_subnet_tags = merge(
    var.public_subnet_tags,
    {
      Company     = var.company
      Environment = var.environment
    }
  )
}

# EKS Auto Mode Cluster with Karpenter
module "eks_auto_mode" {
  source = "../../../modules/AWS/Compute/eks-automode"
  
  cluster_name    = "${var.company}-${var.environment}-eks"
  cluster_version = var.eks_cluster_version
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnets_id_private
  
  # EKS Auto Mode configuration
  eks_auto_mode_enabled    = var.eks_auto_mode_enabled
  eks_auto_mode_node_pools = var.eks_auto_mode_node_pools
  
  # Access configuration
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  
  # Karpenter disabled in Pure Auto Mode
  enable_karpenter = var.enable_karpenter
  
  # Pure Auto Mode custom NodePools
  auto_mode_node_pools = var.auto_mode_node_pools
  
  # All Karpenter-specific configurations commented out for Pure Auto Mode
  # karpenter_version = var.karpenter_version
  # karpenter_tolerations = var.karpenter_tolerations
  # karpenter_node_selector = var.karpenter_node_selector
  # create_default_karpenter_node_pool = var.create_default_karpenter_node_pool
  # karpenter_instance_types = var.karpenter_instance_types
  # karpenter_capacity_types = var.karpenter_capacity_types
  # karpenter_limits = var.karpenter_limits
  # karpenter_disruption_settings = var.karpenter_disruption_settings
  # karpenter_node_pools = var.karpenter_node_pools
  
  # EKS Addons Configuration
  enable_default_addons = var.enable_default_addons
  eks_addon_versions    = var.eks_addon_versions
  cluster_addons        = var.cluster_addons
  
  # Tags
  tags = merge(
    var.common_tags,
    {
      Cluster = "${var.company}-${var.environment}-eks"
    }
  )
  
  # Depends on VPC being created first
  depends_on = [module.vpc]
}
