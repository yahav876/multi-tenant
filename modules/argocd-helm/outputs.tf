# ArgoCD Helm Module Outputs

output "release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = var.namespace
}

output "chart_version" {
  description = "Version of the ArgoCD Helm chart deployed"
  value       = helm_release.argocd.version
}

output "argocd_server_url" {
  description = "ArgoCD server URL (for LoadBalancer service type)"
  value       = var.server_url != "" ? var.server_url : "http://argocd-server.${var.namespace}.svc.cluster.local"
}

output "argocd_admin_password_command" {
  description = "Command to get the ArgoCD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD server"
  value       = "kubectl port-forward svc/argocd-server -n ${var.namespace} 8080:443"
}

output "monitoring_application_created" {
  description = "Whether the monitoring ArgoCD application was created"
  value       = var.create_monitoring_app
}

output "git_ssh_secret_created" {
  description = "Whether the Git SSH secret was created"
  value       = var.git_ssh_private_key != null
}