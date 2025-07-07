# EKS Cluster Outputs
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

# OIDC Outputs
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

# Security Group Outputs
output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_primary_security_group_id
}

# IAM Outputs
output "cluster_iam_role_name" {
  description = "Cluster IAM role name"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM role ARN"
  value       = module.eks.cluster_iam_role_arn
}

output "node_iam_role_name" {
  description = "EKS Auto node IAM role name"
  value       = module.eks.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "EKS Auto node IAM role ARN"
  value       = module.eks.node_iam_role_arn
}

# Karpenter Outputs
output "karpenter_iam_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = var.enable_karpenter ? module.karpenter[0].iam_role_arn : null
}

output "karpenter_node_iam_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = var.enable_karpenter ? module.karpenter[0].node_iam_role_arn : null
}

output "karpenter_node_iam_role_name" {
  description = "Name of the Karpenter node IAM role"
  value       = var.enable_karpenter ? module.karpenter[0].node_iam_role_name : null
}

output "karpenter_instance_profile_name" {
  description = "Name of the Karpenter node instance profile"
  value       = var.enable_karpenter ? aws_iam_instance_profile.karpenter_node[0].name : null
}

output "karpenter_queue_name" {
  description = "Name of the SQS queue for Karpenter"
  value       = var.enable_karpenter ? module.karpenter[0].queue_name : null
}

output "karpenter_queue_arn" {
  description = "ARN of the SQS queue for Karpenter"
  value       = var.enable_karpenter ? module.karpenter[0].queue_arn : null
}

output "karpenter_node_pool_name" {
  description = "Name of the default Karpenter NodePool"
  value       = var.enable_karpenter && var.create_default_karpenter_node_pool ? "${var.cluster_name}-mixed-arch" : null
}

# CloudWatch Log Group
output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_arn
}

# Addon Outputs
output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.eks.cluster_addons
}

# Update Kubeconfig Command
output "update_kubeconfig_command" {
  description = "Command to update local kubeconfig"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
}

# EKS Auto Mode IAM Policy Outputs
output "eks_auto_mode_fleet_policy_arn" {
  description = "ARN of the EKS Auto Mode fleet management policy"
  value       = var.eks_auto_mode_enabled ? aws_iam_policy.eks_auto_mode_fleet_policy[0].arn : null
}
