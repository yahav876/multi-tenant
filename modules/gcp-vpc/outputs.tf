# GCP VPC Module Outputs

output "network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = module.vpc.network_self_link
}

output "network_id" {
  description = "ID of the VPC network"
  value       = module.vpc.network_id
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.vpc.subnets_names
}

output "subnet_self_links" {
  description = "Self links of the subnets"
  value       = module.vpc.subnets_self_links
}

output "subnet_ips" {
  description = "IP ranges of the subnets"
  value       = module.vpc.subnets_ips
}

output "subnet_regions" {
  description = "Regions of the subnets"
  value       = module.vpc.subnets_regions
}

output "secondary_ranges" {
  description = "Secondary IP ranges of the subnets"
  value       = module.vpc.subnets_secondary_ranges
}

# Outputs for GKE cluster configuration
output "primary_subnet_name" {
  description = "Name of the primary subnet for GKE"
  value       = module.vpc.subnets_names[0]
}

output "pods_range_name" {
  description = "Name of the secondary range for pods"
  value       = "gke-pods"
}

output "services_range_name" {
  description = "Name of the secondary range for services"
  value       = "gke-services"
}
