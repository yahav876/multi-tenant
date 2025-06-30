# EKS Auto Mode Module with Karpenter Support

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Enable EKS Auto Mode
  cluster_compute_config = var.eks_auto_mode_enabled ? {
    enabled    = true
    node_pools = var.eks_auto_mode_node_pools
  } : {
    enabled    = false
    node_pools = []
  }

  # Access Configuration
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Authentication
  authentication_mode = var.authentication_mode
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Enable IRSA for Karpenter
  enable_irsa = true

  # Cluster Addons
  cluster_addons = merge(
    {
      coredns = {
        addon_version     = var.eks_addon_versions.coredns
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {
        addon_version     = var.eks_addon_versions.kube_proxy
        resolve_conflicts = "OVERWRITE"
      }
      vpc-cni = {
        addon_version     = var.eks_addon_versions.vpc_cni
        resolve_conflicts = "OVERWRITE"
      }
      aws-ebs-csi-driver = {
        addon_version     = var.eks_addon_versions.aws_ebs_csi_driver
        resolve_conflicts = "OVERWRITE"
        service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      }
      eks-pod-identity-agent = {
        addon_version     = var.eks_addon_versions.eks_pod_identity_agent
        resolve_conflicts = "OVERWRITE"
      }
    },
    var.cluster_addons
  )

  # Security Groups
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  # Cluster Encryption
  cluster_encryption_config = var.cluster_encryption_config

  # CloudWatch Logging
  cluster_enabled_log_types = var.cluster_enabled_log_types

  # Node security group tags for Karpenter discovery
  node_security_group_tags = merge(
    {
      "karpenter.sh/discovery" = var.cluster_name
    },
    var.node_security_group_tags
  )

  # Tags
  tags = var.tags
}

# EBS CSI Driver IRSA
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.30.0"

  create_role                   = true
  role_name                     = "${var.cluster_name}-ebs-csi-driver"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  tags = var.tags
}

# Karpenter Module
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.1"

  count = var.enable_karpenter ? 1 : 0

  cluster_name = module.eks.cluster_name

  # Enable v1 permissions for Karpenter
  enable_v1_permissions = true

  # IRSA configuration
  enable_irsa                       = true
  irsa_oidc_provider_arn           = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts  = ["${var.karpenter_namespace}:karpenter"]

  # Node IAM Role
  create_node_iam_role               = true
  node_iam_role_name                 = "${var.cluster_name}-karpenter-node"
  node_iam_role_use_name_prefix      = false
  node_iam_role_path                 = var.iam_role_path
  node_iam_role_permissions_boundary = null

  # Additional IAM policies for nodes
  node_iam_role_additional_policies = {
    AmazonEKS_CNI_Policy              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEKSWorkerNodePolicy         = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    AmazonSSMManagedInstanceCore      = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

# Create Instance Profile for Karpenter Nodes
resource "aws_iam_instance_profile" "karpenter_node" {
  count = var.enable_karpenter ? 1 : 0

  name = "${var.cluster_name}-karpenter-node-instance-profile"
  role = module.karpenter[0].node_iam_role_name

  tags = var.tags
}

# Helm Release for Karpenter
resource "helm_release" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  namespace        = var.karpenter_namespace
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  values = [
    yamlencode({
      settings = {
        clusterName = module.eks.cluster_name
        # The Karpenter module creates the queue automatically
        interruptionQueueName = module.karpenter[0].queue_name
        featureGates = {
          spotToSpotConsolidation = true
        }
      }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.karpenter[0].iam_role_arn
        }
      }
      tolerations = var.karpenter_tolerations
      nodeSelector = var.karpenter_node_selector
    })
  ]

  depends_on = [
    module.eks,
    module.karpenter
  ]
}

# Karpenter NodePool for mixed architecture (x86 and ARM64)
resource "kubectl_manifest" "karpenter_node_pool" {
  count = var.enable_karpenter && var.create_default_karpenter_node_pool ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "${var.cluster_name}-mixed-arch"
    }
    spec = {
      template = {
        metadata = {
          labels = var.karpenter_node_pool_labels
          annotations = var.karpenter_node_pool_annotations
        }
        spec = {
          requirements = concat([
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = var.karpenter_capacity_types
            },
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.karpenter_instance_types
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64", "arm64"]  # Support both architectures
            }
          ], var.karpenter_node_pool_requirements)
          
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "${var.cluster_name}-node-class"
          }
          
          taints = var.karpenter_node_pool_taints
        }
      }
      
      disruption = var.karpenter_disruption_settings
      
      limits = var.karpenter_limits
    }
  })

  depends_on = [
    helm_release.karpenter
  ]
}

# Karpenter EC2NodeClass
resource "kubectl_manifest" "karpenter_node_class" {
  count = var.enable_karpenter && var.create_default_karpenter_node_pool ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "${var.cluster_name}-node-class"
    }
    spec = {
      instanceStorePolicy = var.karpenter_instance_store_policy
      
      amiSelectorTerms = var.karpenter_ami_selector_terms
      
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      
      instanceProfile = aws_iam_instance_profile.karpenter_node[0].name
      
      userData = var.karpenter_user_data
      
      blockDeviceMappings = var.karpenter_block_device_mappings
      
      tags = merge(
        var.tags,
        var.karpenter_node_tags,
        {
          "karpenter.sh/cluster" = var.cluster_name
        }
      )
    }
  })

  depends_on = [
    kubectl_manifest.karpenter_node_pool
  ]
}

# Additional Custom NodePools
resource "kubectl_manifest" "karpenter_custom_node_pools" {
  for_each = var.enable_karpenter ? var.karpenter_node_pools : {}

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = each.key
    }
    spec = {
      template = {
        metadata = {
          labels = merge(
            {
              "karpenter.sh/nodepool" = each.key
            },
            each.value.labels != null ? each.value.labels : {}
          )
        }
        spec = {
          requirements = concat(
            [
              {
                key      = "karpenter.sh/capacity-type"
                operator = "In"
                values   = each.value.capacity_types != null ? each.value.capacity_types : ["spot", "on-demand"]
              },
              {
                key      = "node.kubernetes.io/instance-type"
                operator = "In"
                values   = each.value.instance_types != null ? each.value.instance_types : var.karpenter_instance_types
              },
              {
                key      = "kubernetes.io/arch"
                operator = "In"
                values   = each.value.architectures != null ? each.value.architectures : ["amd64", "arm64"]
              }
            ],
            each.value.requirements != null ? each.value.requirements : []
          )
          
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = each.value.node_class_name != null ? each.value.node_class_name : "${var.cluster_name}-node-class"
          }
          
          taints = each.value.taints != null ? each.value.taints : []
        }
      }
      
      disruption = each.value.disruption != null ? each.value.disruption : var.karpenter_disruption_settings
      
      limits = each.value.limits != null ? each.value.limits : var.karpenter_limits
    }
  })

  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_node_class
  ]
}
