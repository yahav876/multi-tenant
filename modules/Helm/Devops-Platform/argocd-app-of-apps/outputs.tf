output "app_of_apps_name" {
  value       = kubernetes_manifest.app_of_apps[0].manifest.metadata.name
  description = "Name of the app-of-apps ArgoCD Application"
}

output "services_app_name" {
  value       = kubernetes_manifest.app_of_apps_services[0].manifest.metadata.name
  description = "Name of the services app-of-apps ArgoCD Application"

}
