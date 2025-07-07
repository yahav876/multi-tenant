# Company B - Production Environment Variables

variable "company" {
  description = "Company identifier"
  type        = string
  default     = "company-b"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS/GCP region"
  type        = string
  default     = "us-central1"  # Different region for Company B
}

# AWS specific variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

# VPC Configuration Variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "company-b-production-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"  # Different from company-a to avoid conflicts
}

variable "vpc_azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per availability zone"
  type        = bool
  default     = true  # High availability for production
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default = {
    Type = "Private"
    "kubernetes.io/role/internal-elb" = "1"  # For EKS internal load balancers
    "karpenter.sh/discovery" = "company-b-production-eks"  # For Karpenter subnet discovery
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default = {
    Type = "Public"
    "kubernetes.io/role/elb" = "1"  # For EKS external load balancers
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "company-b-production"
}

# Add more variables as needed for your infrastructure
variable "instance_type" {
  description = "Instance type for compute resources"
  type        = string
  default     = "e2-standard-4"  # GCP instance type for production
}

variable "min_nodes" {
  description = "Minimum number of nodes in cluster"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum number of nodes in cluster"
  type        = number
  default     = 10
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Company     = "company-b"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# EKS Cluster Variables
variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
}

# EKS Addons Configuration
variable "enable_default_addons" {
  description = "Enable default EKS addons (coredns, kube-proxy, vpc-cni, aws-ebs-csi-driver, eks-pod-identity-agent)"
  type        = bool
  default     = true
}

variable "eks_addon_versions" {
  description = "Map of EKS addon versions"
  type = object({
    coredns                = optional(string)
    kube_proxy            = optional(string)
    vpc_cni               = optional(string)
    aws_ebs_csi_driver    = optional(string)
    eks_pod_identity_agent = optional(string)
  })
  default = {
    coredns                = "v1.11.4-eksbuild.14"
    kube_proxy            = "v1.31.0-eksbuild.5"
    vpc_cni               = "v1.19.6-eksbuild.1"
    aws_ebs_csi_driver    = "v1.45.0-eksbuild.2"
    eks_pod_identity_agent = "v1.3.0-eksbuild.1"
  }
}

variable "cluster_addons" {
  description = "Map of EKS addons to install with their configuration"
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts          = optional(string)
    resolve_conflicts_on_create = optional(string)
    resolve_conflicts_on_update = optional(string)
    service_account_role_arn   = optional(string)
    configuration_values       = optional(string)
    preserve                   = optional(bool)
    tags                       = optional(map(string))
  }))
  default = {}
}




# EKS Auto Mode Variables
variable "eks_auto_mode_enabled" {
  description = "Enable EKS Auto Mode"
  type        = bool
  default     = true
}

variable "eks_auto_mode_node_pools" {
  description = "List of node pool names for EKS Auto Mode"
  type        = list(string)
  default     = ["system", "general"]
}

# Karpenter Variables
variable "enable_karpenter" {
  description = "Enable Karpenter for advanced node autoscaling"
  type        = bool
  default     = true
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "1.0.6"
}

variable "karpenter_tolerations" {
  description = "Tolerations for Karpenter pods"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  default = []
}

variable "karpenter_node_selector" {
  description = "Node selector for Karpenter pods"
  type        = map(string)
  default     = {}
}

variable "create_default_karpenter_node_pool" {
  description = "Create a default Karpenter NodePool with mixed architecture support"
  type        = bool
  default     = true
}

variable "karpenter_instance_types" {
  description = "List of instance types for Karpenter (supports both x86 and ARM64)"
  type        = list(string)
  default = [
    # x86_64 instances (AMD64)
    "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge",
    "t3a.medium", "t3a.large", "t3a.xlarge", "t3a.2xlarge",
    "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge",
    "m5a.large", "m5a.xlarge", "m5a.2xlarge", "m5a.4xlarge",
    "m5n.large", "m5n.xlarge", "m5n.2xlarge",
    "c5.large", "c5.xlarge", "c5.2xlarge", "c5.4xlarge",
    "c5n.large", "c5n.xlarge", "c5n.2xlarge",
    "r5.large", "r5.xlarge", "r5.2xlarge",
    # ARM64 instances (Graviton)
    "t4g.medium", "t4g.large", "t4g.xlarge", "t4g.2xlarge",
    "m6g.large", "m6g.xlarge", "m6g.2xlarge", "m6g.4xlarge",
    "m6gd.large", "m6gd.xlarge", "m6gd.2xlarge", "m6gd.4xlarge",
    "c6g.large", "c6g.xlarge", "c6g.2xlarge", "c6g.4xlarge",
    "c6gn.large", "c6gn.xlarge", "c6gn.2xlarge",
    "r6g.large", "r6g.xlarge", "r6g.2xlarge"
  ]
}

variable "karpenter_capacity_types" {
  description = "Capacity types for Karpenter nodes"
  type        = list(string)
  default     = ["spot", "on-demand"]
}

variable "karpenter_limits" {
  description = "Resource limits for Karpenter NodePool"
  type        = map(string)
  default = {
    cpu    = "10000"    # 10,000 vCPUs
    memory = "100000Gi" # 100TB
  }
}

variable "karpenter_disruption_settings" {
  description = "Disruption settings for Karpenter NodePool"
  type = object({
    consolidationPolicy = optional(string)
    consolidateAfter    = optional(string)
    expireAfter        = optional(string)
  })
  default = {
    consolidationPolicy = "WhenEmptyOrUnderutilized"
    consolidateAfter    = "30s"
    expireAfter        = "24h"
  }
}

# Custom Karpenter NodePools
variable "karpenter_node_pools" {
  description = "Map of custom Karpenter NodePools to create"
  type = map(object({
    # Instance configuration
    instance_types = optional(list(string))
    capacity_types = optional(list(string))
    architectures  = optional(list(string))
    
    # Labels and Taints
    labels = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })))
    
    # Additional requirements
    requirements = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })))
    
    # Disruption settings (if different from default)
    disruption = optional(object({
      consolidationPolicy = optional(string)
      consolidateAfter    = optional(string)
      expireAfter        = optional(string)
    }))
    
    # Resource limits (if different from default)
    limits = optional(map(string))
    
    # EC2NodeClass name (if using a custom one)
    node_class_name = optional(string)
  }))
  default = {}
}
