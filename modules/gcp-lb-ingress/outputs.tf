# GCP Load Balancer Controller + Ingress Module Outputs

output "ingress_name" {
  description = "Name of the created ingress"
  value       = kubernetes_ingress_v1.main.metadata[0].name
}

output "ingress_namespace" {
  description = "Namespace of the created ingress"
  value       = kubernetes_ingress_v1.main.metadata[0].namespace
}

output "static_ip_address" {
  description = "The static IP address allocated for the load balancer"
  value       = var.create_static_ip ? google_compute_global_address.lb_ip[0].address : null
}

output "static_ip_name" {
  description = "Name of the static IP address"
  value       = var.create_static_ip ? google_compute_global_address.lb_ip[0].name : var.existing_static_ip_name
}

output "ssl_certificate_name" {
  description = "Name of the managed SSL certificate"
  value       = var.enable_ssl && length(var.ssl_domains) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].name : null
}

output "ssl_certificate_status" {
  description = "Status of the managed SSL certificate"
  value       = var.enable_ssl && length(var.ssl_domains) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].managed[0] : null
}

output "backend_config_name" {
  description = "Name of the BackendConfig resource"
  value       = var.create_backend_config ? kubernetes_manifest.backend_config[0].manifest.metadata.name : null
}

output "frontend_config_name" {
  description = "Name of the FrontendConfig resource"
  value       = var.create_frontend_config ? kubernetes_manifest.frontend_config[0].manifest.metadata.name : null
}

output "health_check_firewall_name" {
  description = "Name of the health check firewall rule"
  value       = var.create_health_check_firewall ? google_compute_firewall.health_check[0].name : null
}

output "access_firewall_name" {
  description = "Name of the load balancer access firewall rule"
  value       = var.create_access_firewall && length(var.authorized_source_ranges) > 0 ? google_compute_firewall.lb_access[0].name : null
}

output "ingress_ip" {
  description = "The external IP address of the load balancer (available after ingress is created)"
  value       = kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].ip
}

output "ingress_hostname" {
  description = "The hostname of the load balancer (if applicable)"
  value       = try(kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "load_balancer_type" {
  description = "Type of load balancer (External or Internal)"
  value       = var.load_balancer_type
}

output "ssl_enabled" {
  description = "Whether SSL is enabled"
  value       = var.enable_ssl
}

output "ssl_domains" {
  description = "List of SSL domains"
  value       = var.ssl_domains
}

output "ingress_class" {
  description = "Ingress class used"
  value       = var.load_balancer_type == "Internal" ? "gce-internal" : "gce"
}

output "ingress_rules" {
  description = "Configured ingress rules"
  value       = var.ingress_rules
}

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "network_name" {
  description = "VPC network name"
  value       = var.network_name
}

output "labels" {
  description = "Applied labels"
  value       = var.labels
}