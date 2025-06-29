# Company B Production Environment Configuration

# Basic configuration
company     = "company-b"
environment = "production"

# AWS Configuration
aws_region = "us-west-2"

# VPC Configuration
vpc_name = "company-b-prod-vpc"
vpc_cidr = "10.20.0.0/16"

# Availability zones (3 for high availability in production)
vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Private subnets (one per AZ)
private_subnet_cidrs = [
  "10.20.1.0/24",   # us-west-2a
  "10.20.2.0/24",   # us-west-2b
  "10.20.3.0/24"    # us-west-2c
]

# Public subnets (one per AZ)
public_subnet_cidrs = [
  "10.20.101.0/24", # us-west-2a
  "10.20.102.0/24", # us-west-2b
  "10.20.103.0/24"  # us-west-2c
]

# NAT Gateway configuration
enable_nat_gateway     = true
one_nat_gateway_per_az = true  # High availability for production

# Subnet tags for EKS compatibility
private_subnet_tags = {
  Type                              = "Private"
  "kubernetes.io/role/internal-elb" = "1"
  "kubernetes.io/cluster/company-b-prod-eks" = "shared"  # Update cluster name as needed
}

public_subnet_tags = {
  Type                     = "Public"
  "kubernetes.io/role/elb" = "1"
  "kubernetes.io/cluster/company-b-prod-eks" = "shared"  # Update cluster name as needed
}

# Common tags
common_tags = {
  Company     = "company-b"
  Environment = "production"
  ManagedBy   = "terraform"
  Project     = "multi-tenant-infrastructure"
  CostCenter  = "company-b-prod"
}

# EKS Configuration
eks_cluster_version = "1.31"

# EKS Access Configuration
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true
# IMPORTANT: Restrict this in production to your IP ranges
cluster_endpoint_public_access_cidrs = ["77.137.76.244/32"]

# EKS Auto Mode Node Pools
eks_auto_mode_node_pools = [
  {
    name = "system"
    instance_types = ["t3.medium", "t3a.medium", "t4g.medium"]  # Mixed architectures
    scaling_config = {
      min_size     = 2
      max_size     = 6
      desired_size = 3
    }
  }
]

# Karpenter Configuration
enable_karpenter = true
karpenter_version = "1.0.6"
create_default_karpenter_node_pool = true

# Karpenter Instance Types - Both x86 and ARM64
karpenter_instance_types = [
  # x86_64 instances for general workloads
  "t3.medium", "t3.large", "t3.xlarge",
  "t3a.medium", "t3a.large", "t3a.xlarge",
  "m5.large", "m5.xlarge", "m5.2xlarge",
  "m5a.large", "m5a.xlarge", "m5a.2xlarge",
  "c5.large", "c5.xlarge", "c5.2xlarge",
  # ARM64 instances for cost optimization
  "t4g.medium", "t4g.large", "t4g.xlarge",
  "m6g.large", "m6g.xlarge", "m6g.2xlarge",
  "m6gd.large", "m6gd.xlarge",
  "c6g.large", "c6g.xlarge", "c6g.2xlarge"
]

# Use both Spot and On-Demand for cost optimization
karpenter_capacity_types = ["spot", "on-demand"]

# Resource limits for production
karpenter_limits = {
  cpu    = "5000"     # 5,000 vCPUs
  memory = "20000Gi"  # 20TB
}

# Disruption settings for production stability
karpenter_disruption_settings = {
  consolidationPolicy = "WhenEmptyOrUnderutilized"
  consolidateAfter    = "60s"  # Wait longer in production
  expireAfter        = "48h"   # Keep nodes longer in production
}
