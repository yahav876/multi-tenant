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

# Monitoring Configuration
variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
}

# Prometheus Configuration
variable "prometheus_chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus data"
  type        = string
}

variable "prometheus_cpu_request" {
  description = "CPU request for Prometheus"
  type        = string
}

variable "prometheus_memory_request" {
  description = "Memory request for Prometheus"
  type        = string
}

variable "prometheus_cpu_limit" {
  description = "CPU limit for Prometheus"
  type        = string
}

variable "prometheus_memory_limit" {
  description = "Memory limit for Prometheus"
  type        = string
}

# Grafana Configuration
variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_storage_size" {
  description = "Storage size for Grafana data"
  type        = string
}

variable "grafana_cpu_request" {
  description = "CPU request for Grafana"
  type        = string
}

variable "grafana_memory_request" {
  description = "Memory request for Grafana"
  type        = string
}

variable "grafana_cpu_limit" {
  description = "CPU limit for Grafana"
  type        = string
}

variable "grafana_memory_limit" {
  description = "Memory limit for Grafana"
  type        = string
}

# Infrastructure Configuration
variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
}

variable "load_balancer_type" {
  description = "Load balancer type for Grafana service (Internal or External)"
  type        = string
}

variable "node_selector" {
  description = "Node selector for monitoring workloads"
  type        = map(string)
  default     = {}
}

# Common labels for all resources
variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
}

# === NEW VARIABLES FOR INGRESS CONFIGURATION ===

# Ingress Configuration
variable "use_ingress" {
  description = "Use Ingress with GCP Load Balancer instead of LoadBalancer service"
  type        = bool
  default     = false
}

# Grafana Ingress Configuration
variable "grafana_enable_ssl" {
  description = "Enable SSL/TLS for Grafana with managed certificates"
  type        = bool
  default     = true
}

variable "grafana_ssl_domains" {
  description = "List of domains for Grafana SSL certificates (e.g., ['grafana.example.com'])"
  type        = list(string)
  default     = []
}

variable "grafana_lb_type" {
  description = "Load balancer type for Grafana ingress (External or Internal)"
  type        = string
  default     = "External"
  validation {
    condition     = contains(["External", "Internal"], var.grafana_lb_type)
    error_message = "grafana_lb_type must be either 'External' or 'Internal'."
  }
}