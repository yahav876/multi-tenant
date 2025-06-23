# File: modules/argocd-helm/variables.tf

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.46.7"
}

variable "values_file_path" {
  description = "Path to ArgoCD Helm chart values file"
  type        = string
  default     = ""
}

variable "git_repo_url" {
  description = "Git repository URL for ArgoCD to monitor"
  type        = string
}

variable "git_ssh_private_key" {
  description = "SSH private key for Git repository access"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to ArgoCD resources"
  type        = map(string)
  default     = {}
}

# App of Apps Configuration
variable "create_app_of_apps" {
  description = "Whether to create the App of Apps ArgoCD application"
  type        = bool
  default     = true
}

variable "app_of_apps_repo_url" {
  description = "Git repository URL for App of Apps manifests"
  type        = string
  default     = ""
}

variable "app_of_apps_repo_revision" {
  description = "Git repository revision/branch for App of Apps manifests"
  type        = string
  default     = "HEAD"
}

variable "app_of_apps_path" {
  description = "Path in the Git repository for App of Apps manifests"
  type        = string
  default     = "applications"
}

# Additional Applications Configuration
variable "additional_applications" {
  description = "List of additional ArgoCD applications to create"
  type = list(object({
    name           = string
    namespace      = string
    repo_url       = string
    target_revision = string
    path           = string
    dest_namespace = string
    project        = optional(string, "default")
    helm_chart     = optional(string, "")
    helm_values    = optional(string, "")
    sync_policy = optional(object({
      automated = optional(object({
        prune       = optional(bool, true)
        self_heal   = optional(bool, true)
        allow_empty = optional(bool, false)
      }), {})
      sync_options = optional(list(string), [
        "CreateNamespace=true",
        "PrunePropagationPolicy=foreground",
        "PruneLast=true",
        "ServerSideApply=true"
      ])
    }), {})
  }))
  default = []
}
