# Company A - Production Environment Outputs

# Project Information
output "project_id" {
  description = "GCP Project ID"
  value       = var.gcp_project_id
}

output "region" {
  description = "GCP Region"
  value       = var.gcp_region
}

# VPC Network Information
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}

output "vpc_network_self_link" {
  description = "Self link of the VPC network"
  value       = module.vpc.network_self_link
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.vpc.subnet_names
}

output "subnet_ips" {
  description = "IP ranges of the subnets"
  value       = module.vpc.subnet_ips
}

# GKE Cluster Information
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster location (region)"
  value       = module.gke.cluster_location
}

output "cluster_zones" {
  description = "GKE cluster zones"
  value       = module.gke.cluster_zones
}

output "node_pools_names" {
  description = "List of node pool names"
  value       = module.gke.node_pools_names
}

output "cluster_master_version" {
  description = "Current master Kubernetes version"
  value       = module.gke.master_version
}

# ArgoCD Information
output "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_url" {
  description = "ArgoCD server URL (use kubectl port-forward to access)"
  value       = "http://localhost:8080"
}

output "argocd_admin_password_command" {
  description = "Command to get the ArgoCD admin password"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD server"
  value       = "kubectl port-forward svc/argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} 8080:443"
}

# Summary Information
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    project_id        = var.gcp_project_id
    region           = var.gcp_region
    cluster_name     = module.gke.cluster_name
    cluster_location = module.gke.cluster_location
    vpc_network      = module.vpc.network_name
    gitops_tool      = "ArgoCD"
    gitops_repo      = var.app_of_apps_repo_url
    node_pools       = module.gke.node_pools_names
  }
}

# ArgoCD Access Instructions
output "argocd_access_info" {
  description = "Information about accessing ArgoCD"
  value = {
    admin_username           = "admin"
    get_password_command     = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    port_forward_command     = "kubectl port-forward svc/argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} 8080:443"
    git_repository          = var.app_of_apps_repo_url
    app_of_apps_path        = var.app_of_apps_path
  }
}
