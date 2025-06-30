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

# EKS Auto Mode Configuration
eks_auto_mode_enabled = true
eks_auto_mode_node_pools = ["system", "general"]

# Karpenter Configuration
enable_karpenter = true
karpenter_version = "1.0.6"
create_default_karpenter_node_pool = false

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

karpenter_node_pools = {
  "x86-nodepool" = {
    architectures  = ["amd64"]
    capacity_types = ["spot", "on-demand"]
    
    # Labels for pod scheduling
    labels = {
      "karpenter.sh/nodepool"     = "x86-nodepool"
      "node.kubernetes.io/arch"   = "amd64"
      "arch-type"                 = "x86"
    }
    
    # Resource limits
    limits = {
      cpu    = "1000"
      memory = "1000Gi"
    }
    
    # Disruption settings for cost optimization
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "300s"
      # expireAfter        = "2h"  # Rotate spot instances more frequently
    }
  },
  
  "graviton-nodepool" = {
    architectures  = ["arm64"]
    capacity_types = ["spot", "on-demand"]
    
    # Labels for pod scheduling
    labels = {
      "karpenter.sh/nodepool"     = "graviton-nodepool"
      "node.kubernetes.io/arch"   = "arm64"
      "arch-type"                 = "graviton"
      "cost-tier"                 = "optimized"  # ARM is more cost-effective
    }
    
    # Resource limits
    limits = {
      cpu    = "1000"
      memory = "1000Gi"
    }
    
    # More aggressive consolidation for ARM (cheaper)
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "300s"
      # expireAfter        = "2h" # Rotate spot instances more frequently
    }
  }
}

# Custom Karpenter NodePools (uncomment and modify as needed)
# karpenter_node_pools = {
#   "example-nodepool-full" = {
#     # Instance configuration
#     instance_types = ["m5.large", "m5.xlarge", "m5a.large", "m5a.xlarge"]  # List of allowed instance types
#     capacity_types = ["spot", "on-demand"]                                  # Can be "spot", "on-demand", or both
#     architectures  = ["amd64", "arm64"]                                     # Can be "amd64", "arm64", or both
#     
#     # Node labels - applied to all nodes in this pool
#     labels = {
#       "nodepool"                = "example-full"
#       "workload-type"          = "general"
#       "team"                   = "platform"
#       "cost-center"            = "engineering"
#       "karpenter.sh/nodepool"  = "example-nodepool-full"  # Automatically added
#     }
#     
#     # Node taints - for pod scheduling restrictions
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "special-workload"
#         effect = "NoSchedule"        # Can be: NoSchedule, PreferNoSchedule, NoExecute
#       },
#       {
#         key    = "team"
#         value  = "platform"
#         effect = "PreferNoSchedule"  # Soft constraint
#       }
#     ]
#     
#     # Additional scheduling requirements
#     requirements = [
#       {
#         key      = "karpenter.k8s.aws/instance-network-bandwidth"
#         operator = "Gt"              # Can be: In, NotIn, Exists, DoesNotExist, Gt, Lt
#         values   = ["10000"]         # Minimum 10 Gbps network
#       },
#       {
#         key      = "karpenter.k8s.aws/instance-hypervisor"
#         operator = "In"
#         values   = ["nitro"]         # Only Nitro instances
#       },
#       {
#         key      = "karpenter.k8s.aws/instance-generation"
#         operator = "Gt"
#         values   = ["4"]             # Generation 5 or newer
#       },
#       {
#         key      = "node.kubernetes.io/instance-type"
#         operator = "NotIn"
#         values   = ["t3.micro", "t3.nano"]  # Exclude tiny instances
#       }
#     ]
#     
#     # Disruption configuration - controls when nodes are removed
#     disruption = {
#       consolidationPolicy = "WhenEmptyOrUnderutilized"  # Options: WhenEmpty, WhenEmptyOrUnderutilized
#       consolidateAfter    = "30s"                       # How long to wait before consolidating
#       expireAfter        = "24h"                        # Node max age before forced replacement
#       
#       # Note: budgets field is not supported in this variable structure
#       # Use kubectl manifest directly if you need disruption budgets
#     }
#     
#     # Resource limits for this NodePool
#     limits = {
#       cpu    = "10000"              # Total vCPUs across all nodes
#       memory = "10000Gi"            # Total memory across all nodes
#       
#       # GPU limits (if using GPU instances)
#       # "nvidia.com/gpu" = "100"
#       
#       # Storage limits
#       # "ephemeral-storage" = "10000Gi"
#       
#       # Custom resource limits
#       # "example.com/special-resource" = "50"
#     }
#     
#     # EC2NodeClass reference (optional - defaults to cluster-wide node class)
#     # Use this if you need a custom AMI, userData, or instance configuration
#     node_class_name = null  # Set to custom EC2NodeClass name if needed
#   },
#   
#   # Minimal example
#   "simple-nodepool" = {
#     instance_types = ["t3.medium"]
#     capacity_types = ["spot"]
#     # All other fields will use defaults
#   }
# }
# 
# # Common Karpenter requirement keys reference:
# # - karpenter.sh/capacity-type: spot, on-demand
# # - kubernetes.io/arch: amd64, arm64
# # - kubernetes.io/os: linux, windows
# # - node.kubernetes.io/instance-type: specific instance types
# # - karpenter.k8s.aws/instance-hypervisor: nitro, xen
# # - karpenter.k8s.aws/instance-network-bandwidth: network bandwidth in Mbps
# # - karpenter.k8s.aws/instance-gpu-name: gpu model names
# # - karpenter.k8s.aws/instance-gpu-manufacturer: nvidia, amd
# # - karpenter.k8s.aws/instance-gpu-count: number of gpus
# # - karpenter.k8s.aws/instance-gpu-memory: gpu memory in MiB
# # - karpenter.k8s.aws/instance-local-nvme: local nvme storage in GB
# # - karpenter.k8s.aws/instance-cpu: number of vcpus
# # - karpenter.k8s.aws/instance-memory: memory in MiB
# # - karpenter.k8s.aws/instance-generation: instance generation number
# # - karpenter.k8s.aws/instance-size: instance size (medium, large, xlarge, etc.)
# # - karpenter.k8s.aws/instance-family: instance family (m5, c5, t3, etc.)
# # - karpenter.k8s.aws/instance-category: general-purpose, compute-optimized, memory-optimized, etc.
# # - karpenter.k8s.aws/instance-encryption-in-transit-supported: true, false
# # - karpenter.k8s.aws/instance-ebs-bandwidth: maximum EBS bandwidth in Mbps
