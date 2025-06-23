# File: modules/argocd-helm/outputs.tf

output "namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
  value       = var.namespace
}

output "release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "argocd_server_url" {
  description = "ArgoCD server URL (use kubectl port-forward to access)"
  value       = "http://localhost:8080"
}

output "argocd_admin_password_command" {
  description = "Command to get the ArgoCD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD server"
  value       = "kubectl port-forward svc/argocd-server -n ${var.namespace} 8080:443"
}

output "app_of_apps_status" {
  description = "Status of the App of Apps application"
  value       = var.create_app_of_apps ? "Created" : "Not created"
}

output "additional_applications_count" {
  description = "Number of additional applications created"
  value       = length(var.additional_applications)
}
