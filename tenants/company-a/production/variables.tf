# File: tenants/company-a/production/variables.tf

# Common labels for all resources
variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
}

# GCP Configuration
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

# VPC Configuration
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
  default     = []
}

# GKE Configuration
variable "cluster_name" {
  description = "Name for the GKE cluster"
  type        = string
}

variable "regional" {
  description = "Whether to use a regional cluster"
  type        = bool
  default     = true
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

variable "node_pools_labels" {
  description = "Labels to set on all node pools"
  type        = map(any)
  default     = {}
}

variable "node_pools_tags" {
  description = "Tags to set on all node pools"
  type        = map(list(string))
  default     = {}
}

variable "identity_namespace" {
  description = "Identity namespace for workload identity"
  type        = string
}

variable "deletion_protection" {
  description = "Whether or not to allow the cluster to be deleted"
  type        = bool
  default     = false
}


variable "services_namespace" {
  description = "Namespace to deploy ArgoCD"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace to deploy ArgoCD"
  type        = string
}

variable "chart_version" {
  description = "Helm chart version for ArgoCD"
  type        = string
}

variable "labels" {
  description = "Labels to add to all resources"
  type        = map(string)
  default     = {}
}

variable "values_file_path" {
  description = "Optional: Path to a custom values.yaml file"
  type        = string
  default     = ""
}


variable "git_ssh_private_key" {
  description = "Contents of the SSH private key for GitOps repo"
  type        = string
  sensitive   = true
}

variable "create_app_of_apps" {
  description = "Whether to create the App of Apps ArgoCD Application"
  type        = bool
  default     = false
}

variable "app_of_apps_repo_url" {
  description = "Git repo for App of Apps"
  type        = string
  default     = ""
}

variable "app_of_apps_repo_revision" {
  description = "Git revision for App of Apps"
  type        = string
  default     = "HEAD"
}

variable "app_of_apps_path" {
  description = "Path in repo for App of Apps"
  type        = string
  default     = "."
}

variable "additional_applications" {
  description = "List of additional applications to create"
  type        = list(any)
  default     = []
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.1.0"    # You can leave this out if you want to force it to be provided in tfvars
}


variable "git_repo_url" {
  description = "Git repo ArgoCD will track"
  type        = string
}


# # ArgoCD Configuration
# variable "argocd_namespace" {
#   description = "Kubernetes namespace for ArgoCD"
#   type        = string
#   default     = "argocd"
# }

# variable "argocd_chart_version" {
#   description = "ArgoCD Helm chart version"
#   type        = string
#   default     = "5.46.7"
# }

# variable "argocd_values_file_path" {
#   description = "Path to ArgoCD Helm chart values file"
#   type        = string
#   default     = ""
# }

# # App of Apps Configuration
# variable "create_app_of_apps" {
#   description = "Whether to create the App of Apps ArgoCD application"
#   type        = bool
#   default     = true
# }

# variable "app_of_apps_repo_url" {
#   description = "Git repository URL for App of Apps manifests"
#   type        = string
#   default     = ""
# }

# variable "app_of_apps_repo_revision" {
#   description = "Git repository revision/branch for App of Apps manifests"
#   type        = string
#   default     = "HEAD"
# }

# variable "app_of_apps_path" {
#   description = "Path in the Git repository for App of Apps manifests"
#   type        = string
#   default     = "applications"
# }

# # Additional Applications Configuration
# variable "additional_applications" {
#   description = "List of additional ArgoCD applications to create"
#   type = list(object({
#     name           = string
#     namespace      = string
#     repo_url       = string
#     target_revision = string
#     path           = string
#     dest_namespace = string
#     project        = optional(string, "default")
#     helm_chart     = optional(string, "")
#     helm_values    = optional(string, "")
#     sync_policy = optional(object({
#       automated = optional(object({
#         prune       = optional(bool, true)
#         self_heal   = optional(bool, true)
#         allow_empty = optional(bool, false)
#       }), {})
#       sync_options = optional(list(string), [
#         "CreateNamespace=true",
#         "PrunePropagationPolicy=foreground",
#         "PruneLast=true",
#         "ServerSideApply=true"
#       ])
#     }), {})
#   }))
#   default = []
# }
