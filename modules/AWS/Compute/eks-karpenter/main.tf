module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  cluster_addons = {
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
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
  }

  }

}


module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.30.0"

  create_role                   = true
  role_name                     = "${var.cluster_name}-ebs-csi-driver"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

}
