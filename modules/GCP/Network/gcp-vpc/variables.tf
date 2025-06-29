variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "vpc_network_name" {
  description = "VPC network name"
  type        = string
}

variable "vpc_routing_mode" {
  description = "VPC routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
}

variable "vpc_subnet_name" {
  description = "Primary subnet name"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the primary subnet"
  type        = string
}

variable "vpc_subnet_private_access" {
  description = "Enable private Google access on the subnet"
  type        = bool
  default     = true
}

variable "vpc_subnet_flow_logs" {
  description = "Enable flow logs on the subnet"
  type        = bool
  default     = true
}

variable "vpc_subnet_description" {
  description = "Description for the subnet"
  type        = string
}

variable "vpc_pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR block for Kubernetes pods (secondary range)"
  type        = string
}

variable "vpc_services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "services_cidr" {
  description = "CIDR block for Kubernetes services (secondary range)"
  type        = string
}

variable "vpc_ingress_rules" {
  description = "List of ingress firewall rules (see terraform-google-modules/network docs)"
  type        = list(any)
}
