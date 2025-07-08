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
  "kubernetes.io/cluster/company-b-production-eks" = "shared"
  "karpenter.sh/discovery" = "company-b-production-eks"
}

public_subnet_tags = {
  Type                     = "Public"
  "kubernetes.io/role/elb" = "1"
  "kubernetes.io/cluster/company-b-production-eks" = "shared"
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

# EKS Addons Configuration
enable_default_addons = true

# Default addon versions
eks_addon_versions = {
  coredns                 = "v1.11.4-eksbuild.14"
  kube_proxy              = "v1.31.0-eksbuild.5"
  vpc_cni                 = "v1.19.6-eksbuild.1"
  aws_ebs_csi_driver      = "v1.45.0-eksbuild.2"
  eks_pod_identity_agent  = "v1.3.0-eksbuild.1"
}

# Additional custom addons (examples - uncomment and modify as needed)
cluster_addons = {
  # Example: AWS Load Balancer Controller
  # aws-load-balancer-controller = {
  #   addon_version     = "v1.8.1-eksbuild.1"
  #   resolve_conflicts = "OVERWRITE"
  #   configuration_values = jsonencode({
  #     clusterName = "company-b-production-eks"
  #     serviceAccount = {
  #       annotations = {
  #         "eks.amazonaws.com/role-arn" = "arn:aws:iam::ACCOUNT:role/AmazonEKSLoadBalancerControllerRole"
  #       }
  #     }
  #   })
  # }
  
  # Example: Amazon CloudWatch Observability
  # amazon-cloudwatch-observability = {
  #   addon_version     = "v1.5.1-eksbuild.1"
  #   resolve_conflicts = "OVERWRITE"
  # }
  
  # Example: AWS EFS CSI Driver
  # aws-efs-csi-driver = {
  #   addon_version     = "v1.7.4-eksbuild.1"
  #   resolve_conflicts = "OVERWRITE"
  #   service_account_role_arn = "arn:aws:iam::ACCOUNT:role/AmazonEKS_EFS_CSI_DriverRole"
  # }
  
  # Example: AWS Secrets Store CSI Driver
  # aws-secrets-store-csi-driver = {
  #   addon_version     = "v1.3.4-eksbuild.1"
  #   resolve_conflicts = "OVERWRITE"
  # }
  
  # Example: AWS VPC CNI Plugin for Kubernetes with custom configuration
  # vpc-cni = {
  #   addon_version     = "v1.19.6-eksbuild.1"
  #   resolve_conflicts = "OVERWRITE"
  #   configuration_values = jsonencode({
  #     env = {
  #       ENABLE_PREFIX_DELEGATION = "true"
  #       ENABLE_POD_ENI = "true"
  #     }
  #   })
  # }
}

# EKS Access Configuration
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true
# IMPORTANT: Restrict this in production to your IP ranges
cluster_endpoint_public_access_cidrs = ["5.29.9.128/32"]

# EKS Auto Mode Configuration - Pure Auto Mode
eks_auto_mode_enabled = true
# Using built-in EKS Auto Mode NodePools only
eks_auto_mode_node_pools = ["system", "general-purpose"]

# Karpenter Configuration - Disabled for Pure Auto Mode
enable_karpenter = false
# karpenter_version = "1.0.6"
# create_default_karpenter_node_pool = false

# Karpenter tolerations - Not needed in Pure Auto Mode
# karpenter_tolerations = [
#   {
#     key      = "CriticalAddonsOnly"
#     operator = "Exists"
#     effect   = "NoSchedule"
#   }
# ]

# Karpenter node selector - Not needed in Pure Auto Mode
# karpenter_node_selector = {
#   "karpenter.sh/nodepool" = "system"
# }

# Pure EKS Auto Mode - Custom NodePools via Terraform
# These NodePools will use EKS Auto Mode's built-in Karpenter
auto_mode_node_pools = {
  "x86-nodepool" = {
    capacity_types = ["spot", "on-demand"]
    architectures  = ["amd64"]
    
    requirements = [
      {
        key      = "eks.amazonaws.com/instance-category"
        operator = "In"
        values   = ["c", "m", "t"]
      },
      {
        key      = "eks.amazonaws.com/instance-generation"
        operator = "Gt"
        values   = ["4"]
      },
      {
        key      = "kubernetes.io/os"
        operator = "In"
        values   = ["linux"]
      }
    ]
    
    # Reference custom EC2NodeClass
    node_class_name = "x86-nodeclass"
    
    labels = {
      "arch-type"      = "x86"
      "workload-type"  = "general"
      "billing-team"   = "company-b"
    }
    
    taints = [
      {
        key    = "arch-type"
        value  = "x86"
        effect = "NoSchedule"
      }
    ]
    
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "300s"
      expireAfter        = "48h"
    }
    
    limits = {
      cpu    = "1000"
      memory = "1000Gi"
    }
  },
  
  "graviton-nodepool" = {
    capacity_types = ["spot", "on-demand"]
    architectures  = ["arm64"]
    
    requirements = [
      {
        key      = "eks.amazonaws.com/instance-category"
        operator = "In"
        values   = ["c", "m", "t"]
      },
      {
        key      = "eks.amazonaws.com/instance-generation"
        operator = "Gt"
        values   = ["4"]
      },
      {
        key      = "kubernetes.io/os"
        operator = "In"
        values   = ["linux"]
      }
    ]
    
    # Reference custom EC2NodeClass
    node_class_name = "graviton-nodeclass"
    
    labels = {
      "arch-type"      = "graviton"
      "workload-type"  = "general"
      "cost-tier"      = "optimized"
      "billing-team"   = "company-b"
    }
    
    taints = [
      {
        key    = "arch-type"
        value  = "graviton"
        effect = "NoSchedule"
      }
    ]
    
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "300s"
      expireAfter        = "24h"  # More aggressive rotation for cost savings
    }
    
    limits = {
      cpu    = "1000"
      memory = "1000Gi"
    }
  }
}

# Custom EC2NodeClass for EKS Auto Mode NodePools
auto_mode_node_classes = {
  "x86-nodeclass" = {
    ami_family = "AL2" # Amazon Linux 2
    
    # Instance requirements for x86 architecture  
    instance_categories = ["c", "m", "t"]
    instance_generations = ["5", "6", "7"]
    
    # Block device mappings
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 20
          volume_type = "gp3"
          delete_on_termination = true
          encrypted = true
        }
      }
    ]
    
    # Metadata options for enhanced security
    metadata_options = {
      http_endpoint = "enabled"
      http_protocol_ipv6 = "disabled"
      http_put_response_hop_limit = 2
      http_tokens = "required"
    }
    
    # User data for additional configuration
    user_data = ""
    
    tags = {
      "arch-type" = "x86"
      "billing-team" = "company-b"
    }
  },
  
  "graviton-nodeclass" = {
    ami_family = "AL2" # Amazon Linux 2
    
    # Instance requirements for ARM64/Graviton architecture
    instance_categories = ["c", "m", "t"]
    instance_generations = ["6", "7"] # Graviton2 and Graviton3
    
    # Block device mappings
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 20
          volume_type = "gp3"
          delete_on_termination = true
          encrypted = true
        }
      }
    ]
    
    # Metadata options for enhanced security
    metadata_options = {
      http_endpoint = "enabled"
      http_protocol_ipv6 = "disabled"
      http_put_response_hop_limit = 2
      http_tokens = "required"
    }
    
    # User data for additional configuration
    user_data = ""
    
    tags = {
      "arch-type" = "graviton"
      "billing-team" = "company-b"
      "cost-tier" = "optimized"
    }
  }
}

# All Karpenter Terraform configuration disabled in Pure Auto Mode:
# - enable_karpenter = false
# - Custom NodePools managed via auto_mode_node_pools above

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
