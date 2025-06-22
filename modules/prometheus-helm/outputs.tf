# Prometheus Module Outputs

output "namespace" {
  description = "Kubernetes namespace for Prometheus"
  value       = var.create_namespace ? kubernetes_namespace.monitoring[0].metadata[0].name : var.namespace
}

output "release_name" {
  description = "Name of the Prometheus Helm release"
  value       = helm_release.prometheus.name
}

output "release_status" {
  description = "Status of the Prometheus Helm release"
  value       = helm_release.prometheus.status
}

output "chart_version" {
  description = "Version of the Prometheus chart deployed"
  value       = helm_release.prometheus.version
}

output "prometheus_url" {
  description = "Internal URL for Prometheus"
  value       = "http://prometheus-kube-prometheus-prometheus.${var.namespace}.svc.cluster.local:9090"
}
