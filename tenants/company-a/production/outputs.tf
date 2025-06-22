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

# Monitoring Information
output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  value       = module.prometheus.namespace
}

output "prometheus_release_status" {
  description = "Status of the Prometheus Helm release"
  value       = module.prometheus.release_status
}

output "grafana_release_status" {
  description = "Status of the Grafana Helm release"
  value       = module.grafana.release_status
}

output "prometheus_url" {
  description = "Internal URL for Prometheus"
  value       = module.prometheus.prometheus_url
}

output "grafana_service_info" {
  description = "Information about accessing Grafana"
  value       = module.grafana.service_info
}

# Connection Commands
output "kubectl_config_command" {
  description = "Command to configure kubectl for this cluster"
  value       = module.gke.kubectl_config_command
}

output "grafana_access_info" {
  description = "Instructions for accessing Grafana"
  value = {
    username = module.grafana.admin_user
    password_note = "Password is set in terraform.tfvars"
    loadbalancer_ip_command = "kubectl get svc grafana -n ${module.prometheus.namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    port_forward_command = "kubectl port-forward -n ${module.prometheus.namespace} svc/grafana 3000:80"
  }
}

# Summary Information
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    company           = var.company
    environment       = var.environment
    project_id        = var.gcp_project_id
    region           = var.gcp_region
    cluster_name     = module.gke.cluster_name
    cluster_location = module.gke.cluster_location
    vpc_network      = module.vpc.network_name
    monitoring_stack = "Prometheus + Grafana"
    node_pools       = module.gke.node_pools_names
  }
}
