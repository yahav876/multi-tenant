# Data 
data "google_client_config" "default" {}


# Common labels for all resources
locals {
  common_labels = merge(var.common_labels, {
    company     = var.company
    environment = var.environment
    terraform   = "true"
    project     = var.gcp_project_id
  })
}

locals {
  vpc_network_name       = "${var.company}-${var.environment}-vpc"
  vpc_subnet_name        = "${var.company}-${var.environment}-subnet"
  vpc_subnet_description = "Primary subnet for ${var.company} ${var.environment}"
  vpc_pods_range_name    = "gke-pods"
  vpc_services_range_name = "gke-services"
}

module "vpc" {
  source  = "../../../modules/gcp-vpc"

  gcp_project_id            = var.gcp_project_id
  gcp_region                = var.gcp_region
  vpc_network_name          = local.vpc_network_name
  vpc_routing_mode          = "REGIONAL"

  vpc_subnet_name           = local.vpc_subnet_name
  subnet_cidr               = var.subnet_cidr
  vpc_subnet_private_access = true
  vpc_subnet_flow_logs      = true
  vpc_subnet_description    = local.vpc_subnet_description

  vpc_pods_range_name       = local.vpc_pods_range_name
  pods_cidr                 = var.pods_cidr
  vpc_services_range_name   = local.vpc_services_range_name
  services_cidr             = var.services_cidr

  vpc_ingress_rules = [
    {
      name          = "${var.company}-${var.environment}-allow-internal"
      description   = "Allow internal communication within VPC"
      priority      = 1000
      source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
      target_tags   = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }, {
        protocol = "udp"
        ports    = ["0-65535"]
      }, {
        protocol = "icmp"
        ports    = []
      }]
    },
    {
      name          = "${var.company}-${var.environment}-allow-ssh"
      description   = "Allow SSH from authorized networks"
      priority      = 1000
      source_ranges = var.authorized_networks
      target_tags   = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name          = "${var.company}-${var.environment}-allow-https"
      description   = "Allow HTTPS from authorized networks"
      priority      = 1000
      source_ranges = var.authorized_networks
      target_tags   = ["gke-node"]
      allow = [{
        protocol = "tcp"
        ports    = ["443"]
      }]
    }
  ]
}



module "gke" {
  source = "../../../modules/gcp-gke"

  project_id   = var.gcp_project_id
  cluster_name = "${var.company}-${var.environment}-cluster"
  region       = var.gcp_region
  regional     = true

  network_name        = module.vpc.network_name
  subnet_name         = module.vpc.primary_subnet_name
  pods_range_name     = module.vpc.pods_range_name
  services_range_name = module.vpc.services_range_name

  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count

  node_pools = [
    {
      name               = "primary-pool"
      machine_type       = var.node_machine_type
      min_count          = var.min_nodes
      max_count          = var.max_nodes
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = var.node_disk_size
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.gke_service_account_email != null ? var.gke_service_account_email : ""
      preemptible        = false
      initial_node_count = var.initial_node_count
    }
  ]

  # Security and features
  network_policy                  = true
  horizontal_pod_autoscaling      = true
  enable_vertical_pod_autoscaling = true
  enable_shielded_nodes           = true
  enable_binary_authorization     = var.enable_binary_authorization

  # Monitoring and logging
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Security
  authorized_networks = var.authorized_networks
  identity_namespace  = "${var.gcp_project_id}.svc.id.goog"

  # Labels and tags
  cluster_resource_labels = local.common_labels
  node_pools_labels = {
    all = local.common_labels
  }
  node_pools_tags = {
    all = ["gke-node", "${var.company}-${var.environment}"]
  }

  # Set deletion_protection to false to allow the cluster to be destroyed
  deletion_protection = false

  depends_on = [module.vpc]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name        = "monitoring"
      company     = var.company
      environment = var.environment
      purpose     = "monitoring"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "services" {
  metadata {
    name = "services"
    labels = {
      name        = "services"
      company     = var.company
      environment = var.environment
      purpose     = "application"
    }
  }
  depends_on = [module.gke]
}


# Deploy Prometheus and Grafana using our modules
module "prometheus" {
  source = "../../../modules/prometheus-helm"

  company     = var.company
  environment = var.environment
  namespace   = var.monitoring_namespace
  
  # Prometheus configuration
  chart_version  = var.prometheus_chart_version
  retention      = var.prometheus_retention
  storage_size   = var.prometheus_storage_size
  cpu_request    = var.prometheus_cpu_request
  memory_request = var.prometheus_memory_request
  cpu_limit      = var.prometheus_cpu_limit
  memory_limit   = var.prometheus_memory_limit
  
  # Infrastructure configuration
  storage_class = var.storage_class
  node_selector = var.node_selector
  labels        = local.common_labels
  
  # Create namespace and wait for GKE cluster
  create_namespace = false
  depends_on = [module.gke, kubernetes_namespace.monitoring]
}

module "grafana" {
  source = "../../../modules/grafana-helm"

  company     = var.company
  environment = var.environment
  namespace   = var.monitoring_namespace
  
  # Grafana configuration
  chart_version  = var.grafana_chart_version
  admin_user     = var.grafana_admin_user
  admin_password = var.grafana_admin_password
  storage_size   = var.grafana_storage_size
  cpu_request    = var.grafana_cpu_request
  memory_request = var.grafana_memory_request
  cpu_limit      = var.grafana_cpu_limit
  memory_limit   = var.grafana_memory_limit
  
  # Infrastructure configuration
  storage_class      = var.storage_class
  node_selector      = var.node_selector
  load_balancer_type = var.load_balancer_type
  labels             = local.common_labels
  
  # Connect to Prometheus
  prometheus_url = module.prometheus.prometheus_url
  
  # Don't create namespace, use the one from Prometheus module
  create_namespace = false
  depends_on = [module.prometheus, kubernetes_namespace.monitoring]
}
