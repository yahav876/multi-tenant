# ArgoCD Helm Module Variables

# Basic Configuration
variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.51.6"
}

variable "argocd_version" {
  description = "ArgoCD application version"
  type        = string
  default     = "v2.9.3"
}

# Service Configuration
variable "service_type" {
  description = "Service type for ArgoCD server (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "service_annotations" {
  description = "Annotations for the ArgoCD server service"
  type        = map(string)
  default     = {}
}

# Ingress Configuration
variable "enable_ingress" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "ingress_hosts" {
  description = "Ingress hosts for ArgoCD"
  type        = list(string)
  default     = []
}

variable "ingress_tls" {
  description = "TLS configuration for ingress"
  type        = list(object({
    secretName = string
    hosts      = list(string)
  }))
  default = []
}

variable "ingress_annotations" {
  description = "Annotations for the ingress"
  type        = map(string)
  default     = {}
}

variable "server_url" {
  description = "ArgoCD server URL"
  type        = string
  default     = ""
}

# Server Configuration
variable "server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "server_cpu_request" {
  description = "CPU request for ArgoCD server"
  type        = string
  default     = "100m"
}

variable "server_memory_request" {
  description = "Memory request for ArgoCD server"
  type        = string
  default     = "128Mi"
}

variable "server_cpu_limit" {
  description = "CPU limit for ArgoCD server"
  type        = string
  default     = "500m"
}

variable "server_memory_limit" {
  description = "Memory limit for ArgoCD server"
  type        = string
  default     = "512Mi"
}

variable "server_extra_args" {
  description = "Extra arguments for ArgoCD server"
  type        = list(string)
  default     = []
}

# Controller Configuration
variable "controller_replicas" {
  description = "Number of ArgoCD application controller replicas"
  type        = number
  default     = 1
}

variable "controller_cpu_request" {
  description = "CPU request for ArgoCD controller"
  type        = string
  default     = "250m"
}

variable "controller_memory_request" {
  description = "Memory request for ArgoCD controller"
  type        = string
  default     = "256Mi"
}

variable "controller_cpu_limit" {
  description = "CPU limit for ArgoCD controller"
  type        = string
  default     = "500m"
}

variable "controller_memory_limit" {
  description = "Memory limit for ArgoCD controller"
  type        = string
  default     = "512Mi"
}

# Repo Server Configuration
variable "repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "repo_server_cpu_request" {
  description = "CPU request for ArgoCD repo server"
  type        = string
  default     = "100m"
}

variable "repo_server_memory_request" {
  description = "Memory request for ArgoCD repo server"
  type        = string
  default     = "128Mi"
}

variable "repo_server_cpu_limit" {
  description = "CPU limit for ArgoCD repo server"
  type        = string
  default     = "1000m"
}

variable "repo_server_memory_limit" {
  description = "Memory limit for ArgoCD repo server"
  type        = string
  default     = "1Gi"
}

# Redis Configuration
variable "redis_cpu_request" {
  description = "CPU request for Redis"
  type        = string
  default     = "100m"
}

variable "redis_memory_request" {
  description = "Memory request for Redis"
  type        = string
  default     = "128Mi"
}

variable "redis_cpu_limit" {
  description = "CPU limit for Redis"
  type        = string
  default     = "200m"
}

variable "redis_memory_limit" {
  description = "Memory limit for Redis"
  type        = string
  default     = "256Mi"
}

# Git Repository Configuration
variable "git_repositories" {
  description = "Git repositories configuration"
  type        = string
  default     = ""
}

variable "git_repo_url" {
  description = "Git repository URL for applications"
  type        = string
  default     = ""
}

variable "git_ssh_private_key" {
  description = "SSH private key for Git repository access"
  type        = string
  default     = null
  sensitive   = true
}

# Monitoring Application Configuration
variable "create_monitoring_app" {
  description = "Whether to create the monitoring ArgoCD application"
  type        = bool
  default     = true
}

variable "monitoring_repo_url" {
  description = "Git repository URL for monitoring manifests"
  type        = string
  default     = ""
}

variable "monitoring_repo_revision" {
  description = "Git repository revision/branch for monitoring manifests"
  type        = string
  default     = "HEAD"
}

variable "monitoring_app_path" {
  description = "Path in the Git repository for monitoring manifests"
  type        = string
  default     = "monitoring"
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

# OIDC Configuration
variable "oidc_config" {
  description = "OIDC configuration for ArgoCD"
  type        = string
  default     = ""
}

# Infrastructure Configuration
variable "node_selector" {
  description = "Node selector for ArgoCD pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for ArgoCD pods"
  type        = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "affinity" {
  description = "Affinity for ArgoCD pods"
  type        = any
  default     = {}
}

# Labels
variable "labels" {
  description = "Labels to apply to ArgoCD resources"
  type        = map(string)
  default     = {}
}