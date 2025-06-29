# GKE Cluster Module Outputs

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = module.gke.location
}

output "cluster_zones" {
  description = "GKE cluster zones"
  value       = module.gke.zones
}

output "node_pools_names" {
  description = "List of node pool names"
  value       = module.gke.node_pools_names
}

output "node_pools_versions" {
  description = "Node pool versions"
  value       = module.gke.node_pools_versions
}

output "service_account" {
  description = "The service account used for nodes"
  value       = module.gke.service_account
}

output "identity_namespace" {
  description = "Workload Identity namespace"
  value       = module.gke.identity_namespace
}

output "master_version" {
  description = "Current master Kubernetes version"
  value       = module.gke.master_version
}

# Connection info for kubectl
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.name} --region ${module.gke.location} --project ${var.project_id}"
}
