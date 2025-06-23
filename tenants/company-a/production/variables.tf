# Company A - Production Environment Variables

# General configuration
variable "company" {
  description = "Company identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Provider variables
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
}

# Networking
variable "subnet_cidr" {
  description = "CIDR block for the main subnet"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR block for Kubernetes pods"
  type        = string
}

variable "services_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
}

variable "authorized_networks" {
  description = "List of CIDR blocks that can access the GKE cluster master"
  type        = list(string)
}

# GKE Configuration
variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "min_nodes" {
  description = "Minimum number of nodes in the GKE cluster"
  type        = number
}

variable "max_nodes" {
  description = "Maximum number of nodes in the GKE cluster"
  type        = number
}

variable "node_disk_size" {
  description = "Disk size in GB for GKE nodes"
  type        = number
}

variable "initial_node_count" {
  description = "Initial number of nodes in the node pool"
  type        = number
}

variable "gke_service_account_email" {
  description = "Service account email for GKE nodes (optional)"
  type        = string
  default     = null
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for enhanced security"
  type        = bool
}

# Monitoring Configuration (for ArgoCD managed monitoring)
variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
}

# ArgoCD Configuration
variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.51.6"
}

variable "argocd_version" {
  description = "ArgoCD application version"
  type        = string
  default     = "v2.9.3"
}

variable "argocd_service_type" {
  description = "Service type for ArgoCD server (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "LoadBalancer"
}

variable "argocd_service_annotations" {
  description = "Annotations for the ArgoCD server service"
  type        = map(string)
  default     = {}
}

variable "argocd_enable_ingress" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "argocd_ingress_hosts" {
  description = "Ingress hosts for ArgoCD"
  type        = list(string)
  default     = []
}

variable "argocd_ingress_annotations" {
  description = "Annotations for the ArgoCD ingress"
  type        = map(string)
  default     = {}
}

variable "argocd_server_url" {
  description = "ArgoCD server URL"
  type        = string
  default     = ""
}

# ArgoCD Server Resource Configuration
variable "argocd_server_cpu_request" {
  description = "CPU request for ArgoCD server"
  type        = string
  default     = "100m"
}

variable "argocd_server_memory_request" {
  description = "Memory request for ArgoCD server"
  type        = string
  default     = "128Mi"
}

variable "argocd_server_cpu_limit" {
  description = "CPU limit for ArgoCD server"
  type        = string
  default     = "500m"
}

variable "argocd_server_memory_limit" {
  description = "Memory limit for ArgoCD server"
  type        = string
  default     = "512Mi"
}

# ArgoCD Controller Resource Configuration
variable "argocd_controller_cpu_request" {
  description = "CPU request for ArgoCD controller"
  type        = string
  default     = "250m"
}

variable "argocd_controller_memory_request" {
  description = "Memory request for ArgoCD controller"
  type        = string
  default     = "256Mi"
}

variable "argocd_controller_cpu_limit" {
  description = "CPU limit for ArgoCD controller"
  type        = string
  default     = "500m"
}

variable "argocd_controller_memory_limit" {
  description = "Memory limit for ArgoCD controller"
  type        = string
  default     = "512Mi"
}

# ArgoCD Repo Server Resource Configuration
variable "argocd_repo_cpu_request" {
  description = "CPU request for ArgoCD repo server"
  type        = string
  default     = "100m"
}

variable "argocd_repo_memory_request" {
  description = "Memory request for ArgoCD repo server"
  type        = string
  default     = "128Mi"
}

variable "argocd_repo_cpu_limit" {
  description = "CPU limit for ArgoCD repo server"
  type        = string
  default     = "1000m"
}

variable "argocd_repo_memory_limit" {
  description = "Memory limit for ArgoCD repo server"
  type        = string
  default     = "1Gi"
}

# Git Repository Configuration for ArgoCD
variable "monitoring_repo_url" {
  description = "Git repository URL for monitoring manifests"
  type        = string
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

variable "git_ssh_private_key" {
  description = "SSH private key for Git repository access"
  type        = string
  default     = null
  sensitive   = true
}

variable "create_monitoring_app" {
  description = "Whether to create the monitoring ArgoCD application"
  type        = bool
  default     = true
}

# Infrastructure Configuration
variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
}

variable "node_selector" {
  description = "Node selector for workloads"
  type        = map(string)
  default     = {}
}

# Common labels for all resources
variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
}

