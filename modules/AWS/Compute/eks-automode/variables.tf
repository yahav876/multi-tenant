# EKS Cluster Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

# Network Variables
variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the nodes will be deployed"
  type        = list(string)
}

# EKS Auto Mode Configuration
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

# Access Configuration
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
  default     = ["0.0.0.0/0"]
}

# Authentication
variable "authentication_mode" {
  description = "The authentication mode for the cluster"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the cluster creator"
  type        = bool
  default     = true
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

# Security Groups
variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for the cluster security group"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the node security group"
  type        = any
  default     = {}
}

variable "node_security_group_tags" {
  description = "Additional tags for the node security group"
  type        = map(string)
  default     = {}
}

# Encryption
variable "cluster_encryption_config" {
  description = "Cluster encryption configuration"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

# Logging
variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

# Karpenter Configuration
variable "enable_karpenter" {
  description = "Enable Karpenter for autoscaling"
  type        = bool
  default     = true
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter"
  type        = string
  default     = "karpenter"
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
  description = "Create a default Karpenter NodePool"
  type        = bool
  default     = true
}

variable "karpenter_node_pool_labels" {
  description = "Labels to apply to Karpenter provisioned nodes"
  type        = map(string)
  default = {
    "karpenter.sh/managed-by" = "karpenter"
  }
}

variable "karpenter_node_pool_annotations" {
  description = "Annotations to apply to Karpenter provisioned nodes"
  type        = map(string)
  default     = {}
}

variable "karpenter_capacity_types" {
  description = "List of capacity types for Karpenter nodes"
  type        = list(string)
  default     = ["spot", "on-demand"]
}

variable "karpenter_instance_types" {
  description = "List of instance types for Karpenter to use"
  type        = list(string)
  default = [
    # x86_64 instances
    "t3.medium", "t3.large", "t3.xlarge",
    "t3a.medium", "t3a.large", "t3a.xlarge",
    "m5.large", "m5.xlarge", "m5.2xlarge",
    "m5a.large", "m5a.xlarge", "m5a.2xlarge",
    # ARM64 instances
    "t4g.medium", "t4g.large", "t4g.xlarge",
    "m6g.large", "m6g.xlarge", "m6g.2xlarge",
    "m6gd.large", "m6gd.xlarge", "m6gd.2xlarge"
  ]
}

variable "karpenter_node_pool_requirements" {
  description = "Additional requirements for Karpenter NodePool"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = []
}

variable "karpenter_node_pool_taints" {
  description = "Taints to apply to Karpenter provisioned nodes"
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = []
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

variable "karpenter_limits" {
  description = "Resource limits for Karpenter NodePool"
  type        = map(string)
  default = {
    cpu    = "10000"
    memory = "10000Gi"
  }
}

variable "karpenter_instance_store_policy" {
  description = "Instance store policy for Karpenter EC2NodeClass"
  type        = string
  default     = "RAID0"
}

variable "karpenter_ami_selector_terms" {
  description = "AMI selector terms for Karpenter EC2NodeClass"
  type = list(object({
    alias = optional(string)
    id    = optional(string)
    name  = optional(string)
    owner = optional(string)
  }))
  default = [
    {
      alias = "al2023@latest"
    }
  ]
}

variable "karpenter_user_data" {
  description = "User data script for Karpenter nodes"
  type        = string
  default     = ""
}

variable "karpenter_block_device_mappings" {
  description = "Block device mappings for Karpenter nodes"
  type = list(object({
    deviceName = string
    ebs = optional(object({
      deleteOnTermination = optional(bool)
      encrypted          = optional(bool)
      kmsKeyID          = optional(string)
      snapshotID        = optional(string)
      volumeSize        = optional(string)
      volumeType        = optional(string)
    }))
  }))
  default = [
    {
      deviceName = "/dev/xvda"
      ebs = {
        deleteOnTermination = true
        encrypted          = true
        volumeSize         = "100Gi"
        volumeType         = "gp3"
      }
    }
  ]
}

variable "karpenter_node_tags" {
  description = "Additional tags for Karpenter nodes"
  type        = map(string)
  default     = {}
}

# Custom NodePools Configuration
variable "karpenter_node_pools" {
  description = "Map of Karpenter NodePools to create"
  type = map(object({
    # Requirements
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
    
    # Requirements
    requirements = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })))
    
    # Disruption settings
    disruption = optional(object({
      consolidationPolicy = optional(string)
      consolidateAfter    = optional(string)
      expireAfter        = optional(string)
    }))
    
    # Limits
    limits = optional(map(string))
    
    # Node class name (if different from default)
    node_class_name = optional(string)
  }))
  default = {}
}

# Auto Mode Custom NodePools Configuration (for Pure Auto Mode)
variable "auto_mode_node_pools" {
  description = "Map of custom NodePools to create for EKS Auto Mode (uses built-in Karpenter)"
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
    
    # Disruption settings
    disruption = optional(object({
      consolidationPolicy = optional(string)
      consolidateAfter    = optional(string)
      expireAfter        = optional(string)
    }))
    
    # Resource limits
    limits = optional(map(string))
    
    # NodeClass reference
    node_class_name = optional(string, null)
  }))
  default = {}
}

# IAM
variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

# Auto Mode Node Classes
variable "auto_mode_node_classes" {
  description = "Custom NodeClass configurations for EKS Auto Mode"
  type = map(object({
    ami_family = optional(string, "AL2")
    
    # Instance requirements
    instance_categories  = optional(list(string), ["c", "m", "t"])
    instance_generations = optional(list(string), ["5", "6", "7"])
    architectures       = optional(list(string), ["amd64"])
    
    # Block device mappings
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = object({
        volume_size           = optional(number, 20)
        volume_type          = optional(string, "gp3")
        delete_on_termination = optional(bool, true)
        encrypted            = optional(bool, true)
      })
    })), [])
    
    # Metadata options
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_protocol_ipv6         = optional(string, "disabled")
      http_put_response_hop_limit = optional(number, 2)
      http_tokens                = optional(string, "required")
    }), {})
    
    # User data
    user_data = optional(string, "")
    
    # Instance profile
    instance_profile = optional(string, null)
    
    # Additional tags for instances
    instance_tags = optional(map(string), {})
  }))
  default = {}
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
