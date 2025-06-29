# Grafana Module Outputs

output "namespace" {
  description = "Kubernetes namespace for Grafana"
  value       = var.create_namespace ? kubernetes_namespace.monitoring[0].metadata[0].name : var.namespace
}

output "release_name" {
  description = "Name of the Grafana Helm release"
  value       = helm_release.grafana.name
}

output "release_status" {
  description = "Status of the Grafana Helm release"
  value       = helm_release.grafana.status
}

output "chart_version" {
  description = "Version of the Grafana chart deployed"
  value       = helm_release.grafana.version
}

output "admin_user" {
  description = "Grafana admin username"
  value       = var.admin_user
}

output "service_info" {
  description = "Information about accessing Grafana"
  value = {
    namespace = var.namespace
    username  = var.admin_user
    note      = "Get the LoadBalancer IP with: kubectl get svc grafana -n ${var.namespace}"
  }
}
