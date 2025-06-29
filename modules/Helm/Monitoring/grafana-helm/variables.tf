# Grafana Module Variables

variable "company" {
  description = "Company identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Grafana"
  type        = string
  default     = "monitoring"
}

variable "create_namespace" {
  description = "Whether to create the namespace or use an existing one"
  type        = bool
  default     = false
}

# Grafana Configuration
variable "chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
  default     = "7.3.0"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "Storage size for Grafana"
  type        = string
  default     = "10Gi"
}

variable "cpu_request" {
  description = "CPU request for Grafana"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request for Grafana"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit for Grafana"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit for Grafana"
  type        = string
  default     = "1Gi"
}

# Infrastructure Configuration
variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "standard-rwo"
}

variable "node_selector" {
  description = "Node selector for pod placement"
  type        = map(string)
  default     = {}
}

variable "load_balancer_type" {
  description = "Load balancer type for Grafana service (used when service_type is LoadBalancer)"
  type        = string
  default     = "Internal"
}

variable "service_type" {
  description = "Kubernetes service type (LoadBalancer or ClusterIP). Use ClusterIP when using Ingress."
  type        = string
  default     = "LoadBalancer"
  validation {
    condition     = contains(["LoadBalancer", "ClusterIP"], var.service_type)
    error_message = "service_type must be either 'LoadBalancer' or 'ClusterIP'."
  }
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_url" {
  description = "URL of the Prometheus server to use as a data source"
  type        = string
}
