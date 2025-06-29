output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  value = module.eks.eks_managed_node_groups_autoscaling_group_names
}

