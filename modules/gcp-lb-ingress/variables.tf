# GCP Load Balancer Controller + Ingress Module Variables

# === REQUIRED VARIABLES ===

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where the ingress will be created"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    host = string
    paths = list(object({
      path         = string
      path_type    = string # Exact, Prefix, or ImplementationSpecific
      service_name = string
      service_port = number
    }))
  }))
  default = []
}

# === STATIC IP CONFIGURATION ===

variable "create_static_ip" {
  description = "Whether to create a new static IP address"
  type        = bool
  default     = true
}

variable "existing_static_ip_name" {
  description = "Name of existing static IP address to use (if create_static_ip is false)"
  type        = string
  default     = ""
}

# === SSL/TLS CONFIGURATION ===

variable "enable_ssl" {
  description = "Enable SSL/TLS with managed certificates"
  type        = bool
  default     = true
}

variable "ssl_domains" {
  description = "List of domains for managed SSL certificates"
  type        = list(string)
  default     = []
}

variable "tls_secret_name" {
  description = "Name of TLS secret (optional, for custom certificates)"
  type        = string
  default     = ""
}

variable "ssl_policy_name" {
  description = "Name of SSL policy to apply"
  type        = string
  default     = ""
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}

variable "allow_http" {
  description = "Allow HTTP traffic (false will force HTTPS only)"
  type        = bool
  default     = false
}

# === LOAD BALANCER CONFIGURATION ===

variable "load_balancer_type" {
  description = "Type of load balancer (External or Internal)"
  type        = string
  default     = "External"
  validation {
    condition     = contains(["External", "Internal"], var.load_balancer_type)
    error_message = "load_balancer_type must be either 'External' or 'Internal'."
  }
}

variable "default_backend_service" {
  description = "Default backend service name"
  type        = string
  default     = ""
}

variable "default_backend_port" {
  description = "Default backend service port"
  type        = number
  default     = 80
}

# === BACKEND CONFIGURATION ===

variable "create_backend_config" {
  description = "Create BackendConfig resource for advanced backend settings"
  type        = bool
  default     = true
}

variable "backend_timeout" {
  description = "Backend service timeout in seconds"
  type        = number
  default     = 30
}

variable "connection_draining_timeout" {
  description = "Connection draining timeout in seconds"
  type        = number
  default     = 60
}

variable "session_affinity_type" {
  description = "Session affinity type (CLIENT_IP, GENERATED_COOKIE, etc.)"
  type        = string
  default     = "NONE"
}

variable "session_affinity_cookie_ttl" {
  description = "Session affinity cookie TTL in seconds"
  type        = number
  default     = 86400
}

# === HEALTH CHECK CONFIGURATION ===

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 80
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 10
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of successful health checks before marking healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of failed health checks before marking unhealthy"
  type        = number
  default     = 3
}

variable "health_check_type" {
  description = "Health check type (HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
}

# === CDN CONFIGURATION ===

variable "enable_cdn" {
  description = "Enable Cloud CDN"
  type        = bool
  default     = false
}

variable "cdn_include_query_string" {
  description = "Include query string in CDN cache key"
  type        = bool
  default     = false
}

# === SECURITY CONFIGURATION ===

variable "security_policy_name" {
  description = "Name of Cloud Armor security policy"
  type        = string
  default     = ""
}

variable "authorized_source_ranges" {
  description = "List of authorized source IP ranges for firewall rules"
  type        = list(string)
  default     = []
}

variable "target_tags" {
  description = "Target tags for firewall rules"
  type        = list(string)
  default     = ["gke-node"]
}

variable "create_health_check_firewall" {
  description = "Create firewall rule for health checks"
  type        = bool
  default     = true
}

variable "create_access_firewall" {
  description = "Create firewall rule for load balancer access"
  type        = bool
  default     = true
}

# === FRONTEND CONFIGURATION ===

variable "create_frontend_config" {
  description = "Create FrontendConfig resource"
  type        = bool
  default     = false
}

variable "frontend_config_name" {
  description = "Name of existing FrontendConfig to use"
  type        = string
  default     = ""
}

# === ANNOTATIONS AND LABELS ===

variable "custom_annotations" {
  description = "Custom annotations for the ingress"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# === COMPANY/ENVIRONMENT CONTEXT ===

variable "company" {
  description = "Company identifier"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (production, staging, etc.)"
  type        = string
  default     = ""
}