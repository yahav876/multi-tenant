variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name for the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "regional" {
  description = "Whether to use a regional cluster"
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "remove_default_node_pool" {
  description = "Whether to remove the default node pool"
  type        = bool
  default     = true
}

variable "initial_node_count" {
  description = "Initial number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_pools" {
  description = "List of maps defining node pools"
  type = list(object({
    name               = string
    machine_type       = string
    min_count          = number
    max_count          = number
    local_ssd_count    = number
    spot               = bool
    disk_size_gb       = number
    disk_type          = string
    image_type         = string
    enable_gcfs        = bool
    enable_gvnic       = bool
    auto_repair        = bool
    auto_upgrade       = bool
    service_account    = string
    preemptible        = bool
    initial_node_count = number
  }))
}

variable "network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable vertical pod autoscaling"
  type        = bool
  default     = true
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = true
}

variable "logging_service" {
  description = "Logging service"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "Monitoring service"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "authorized_networks" {
  description = "List of CIDR blocks allowed to access the GKE master"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_resource_labels" {
  description = "Labels to set on the cluster resource"
  type        = map(string)
}

variable "node_pools_labels" {
  description = "Labels to set on all node pools"
  type        = map(any)
}

variable "node_pools_tags" {
  description = "Tags to set on all node pools"
  type        = map(list(string))
}

variable "identity_namespace" {
  description = "Identity namespace for workload identity"
  type        = string
}
