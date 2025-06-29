# Outputs for Company B Production Environment

# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.subnets_id_private
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.subnets_id_public
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.azs_passed_to_module
}

# Additional outputs for reference
output "vpc_name" {
  description = "Name of the VPC"
  value       = var.vpc_name
}

output "nat_gateway_count" {
  description = "Number of NAT gateways created"
  value       = var.one_nat_gateway_per_az ? length(var.vpc_azs) : 1
}

# EKS Outputs
output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks_auto_mode.cluster_id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_auto_mode.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks_auto_mode.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = module.eks_auto_mode.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_auto_mode.cluster_arn
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks_auto_mode.cluster_oidc_issuer_url
}

output "eks_cluster_security_group_id" {
  description = "Security group ID of the cluster"
  value       = module.eks_auto_mode.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "Security group ID of the nodes"
  value       = module.eks_auto_mode.node_security_group_id
}

# Karpenter Outputs
output "karpenter_iam_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = module.eks_auto_mode.karpenter_iam_role_arn
}

output "karpenter_instance_profile_name" {
  description = "Name of the Karpenter node instance profile"
  value       = module.eks_auto_mode.karpenter_instance_profile_name
}

output "karpenter_queue_name" {
  description = "Name of the SQS queue for Karpenter"
  value       = module.eks_auto_mode.karpenter_queue_name
}

# Update kubeconfig command
output "update_kubeconfig_command" {
  description = "Command to update local kubeconfig"
  value       = module.eks_auto_mode.update_kubeconfig_command
}
