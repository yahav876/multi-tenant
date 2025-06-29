# Example: Custom NodePools Configuration
# Uncomment and modify this to create custom NodePools

# locals {
#   karpenter_node_pools = {
#     # GPU NodePool for ML workloads
#     "gpu-nodes" = {
#       instance_types = ["g4dn.xlarge", "g4dn.2xlarge", "g4dn.4xlarge"]
#       capacity_types = ["on-demand"]  # GPUs usually on-demand
#       architectures  = ["amd64"]      # GPU instances are x86 only
#       
#       labels = {
#         workload-type = "gpu"
#         team          = "ml-team"
#       }
#       
#       taints = [{
#         key    = "nvidia.com/gpu"
#         value  = "true"
#         effect = "NoSchedule"
#       }]
#       
#       limits = {
#         cpu    = "1000"
#         memory = "1000Gi"
#         "nvidia.com/gpu" = "10"  # Max 10 GPUs
#       }
#     }
#     
#     # High-performance compute nodes
#     "compute-optimized" = {
#       instance_types = ["c5n.large", "c5n.xlarge", "c5n.2xlarge", "c5n.4xlarge"]
#       capacity_types = ["spot", "on-demand"]
#       architectures  = ["amd64"]
#       
#       labels = {
#         workload-type = "compute-intensive"
#         performance   = "high"
#       }
#       
#       requirements = [{
#         key      = "karpenter.k8s.aws/instance-network-bandwidth"
#         operator = "Gt"
#         values   = ["10000"]  # High network bandwidth
#       }]
#     }
#     
#     # Cost-optimized ARM nodes
#     "arm-spot-only" = {
#       instance_types = ["t4g.medium", "t4g.large", "m6g.medium", "m6g.large"]
#       capacity_types = ["spot"]  # Spot only for cost savings
#       architectures  = ["arm64"]
#       
#       labels = {
#         workload-type = "cost-optimized"
#         architecture  = "arm64"
#       }
#       
#       disruption = {
#         consolidationPolicy = "WhenEmptyOrUnderutilized"
#         consolidateAfter    = "30s"
#         expireAfter        = "2h"  # Shorter expiration for spot
#       }
#     }
#     
#     # Memory-optimized nodes for databases
#     "memory-optimized" = {
#       instance_types = ["r5.large", "r5.xlarge", "r5.2xlarge", "r6g.large", "r6g.xlarge"]
#       capacity_types = ["on-demand"]  # Stable for databases
#       architectures  = ["amd64", "arm64"]
#       
#       labels = {
#         workload-type = "memory-intensive"
#         suitable-for  = "databases"
#       }
#       
#       taints = [{
#         key    = "workload-type"
#         value  = "database"
#         effect = "NoSchedule"
#       }]
#     }
#     
#     # Development/test nodes with relaxed limits
#     "dev-nodes" = {
#       instance_types = ["t3.small", "t3.medium", "t3a.small", "t3a.medium"]
#       capacity_types = ["spot"]
#       architectures  = ["amd64"]
#       
#       labels = {
#         environment = "development"
#         cost-tier   = "low"
#       }
#       
#       disruption = {
#         consolidationPolicy = "WhenEmptyOrUnderutilized"
#         consolidateAfter    = "10s"  # Aggressive consolidation
#         expireAfter        = "30m"   # Quick turnover
#       }
#       
#       limits = {
#         cpu    = "100"
#         memory = "100Gi"
#       }
#     }
#   }
# }

# Then in your module call, add:
# module "eks_auto_mode" {
#   ...
#   
#   # Disable default NodePool if you only want custom ones
#   # create_default_karpenter_node_pool = false
#   
#   # Add custom NodePools
#   karpenter_node_pools = local.karpenter_node_pools
# }
