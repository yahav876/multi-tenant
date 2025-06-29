module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "37.0.0"

  project_id = var.project_id
  name       = var.cluster_name
  region     = var.region
  regional   = var.regional

  # Network configuration
  network    = var.network_name
  subnetwork = var.subnet_name

  # Secondary ranges for pods and services
  ip_range_pods     = var.pods_range_name
  ip_range_services = var.services_range_name

  # Remove default node pool - we'll create custom ones
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count

  # Node pools configuration
  node_pools = var.node_pools

  # Security and compliance features
  network_policy                  = var.network_policy
  horizontal_pod_autoscaling      = var.horizontal_pod_autoscaling
  enable_vertical_pod_autoscaling = var.enable_vertical_pod_autoscaling
  enable_shielded_nodes           = var.enable_shielded_nodes
  enable_binary_authorization     = var.enable_binary_authorization

  # Logging and monitoring
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # Master authorized networks for security
  master_authorized_networks = [
    for cidr in var.authorized_networks : {
      cidr_block   = cidr
      display_name = "authorized-network"
    }
  ]

  # Resource labels
  cluster_resource_labels = var.cluster_resource_labels

  # Node pool labels and tags
  node_pools_labels = var.node_pools_labels
  node_pools_tags   = var.node_pools_tags

  # Workload Identity for secure access to GCP services
  identity_namespace = var.identity_namespace
  
  # Control deletion protection
  deletion_protection = var.deletion_protection
}
