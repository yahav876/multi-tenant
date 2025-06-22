# Prometheus Module Variables

variable "company" {
  description = "Company identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Prometheus"
  type        = string
  default     = "monitoring"
}

variable "create_namespace" {
  description = "Whether to create the namespace or use an existing one"
  type        = bool
  default     = true
}

# Prometheus Configuration
variable "chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "56.0.0"
}

variable "retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "30d"
}

variable "storage_size" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "50Gi"
}

variable "cpu_request" {
  description = "CPU request for Prometheus"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request for Prometheus"
  type        = string
  default     = "2Gi"
}

variable "cpu_limit" {
  description = "CPU limit for Prometheus"
  type        = string
  default     = "2000m"
}

variable "memory_limit" {
  description = "Memory limit for Prometheus"
  type        = string
  default     = "8Gi"
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

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_alertmanager" {
  description = "Whether to enable AlertManager"
  type        = bool
  default     = false
}
