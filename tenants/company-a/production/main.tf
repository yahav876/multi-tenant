# File: tenants/company-a/production/main.tf

# Data source for Google client configuration
data "google_client_config" "default" {}

# Local values
locals {
  common_labels = var.common_labels
  
  # SSH key for ArgoCD Git repository access
  argocd_ssh_key = file("${path.module}/argocd-ssh-key")
}

# VPC Module
module "vpc" {
  source = "../../../modules/gcp-vpc"

  gcp_project_id              = var.gcp_project_id
  gcp_region                  = var.gcp_region
  vpc_network_name            = var.vpc_network_name
  vpc_routing_mode            = var.vpc_routing_mode
  vpc_subnet_name             = var.vpc_subnet_name
  subnet_cidr                 = var.subnet_cidr
  vpc_subnet_private_access   = var.vpc_subnet_private_access
  vpc_subnet_flow_logs        = var.vpc_subnet_flow_logs
  vpc_subnet_description      = var.vpc_subnet_description
  vpc_pods_range_name         = var.vpc_pods_range_name
  pods_cidr                   = var.pods_cidr
  vpc_services_range_name     = var.vpc_services_range_name
  services_cidr               = var.services_cidr
  vpc_ingress_rules           = var.vpc_ingress_rules
}

# GKE Module
module "gke" {
  source = "../../../modules/gcp-gke"

  project_id                         = var.gcp_project_id
  cluster_name                       = var.cluster_name
  region                             = var.gcp_region
  regional                           = var.regional
  network_name                       = module.vpc.network_name
  subnet_name                        = module.vpc.primary_subnet_name
  pods_range_name                    = var.vpc_pods_range_name
  services_range_name                = var.vpc_services_range_name
  remove_default_node_pool           = var.remove_default_node_pool
  initial_node_count                 = var.initial_node_count
  node_pools                         = var.node_pools
  network_policy                     = var.network_policy
  horizontal_pod_autoscaling         = var.horizontal_pod_autoscaling
  enable_vertical_pod_autoscaling    = var.enable_vertical_pod_autoscaling
  enable_shielded_nodes              = var.enable_shielded_nodes
  enable_binary_authorization        = var.enable_binary_authorization
  logging_service                    = var.logging_service
  monitoring_service                 = var.monitoring_service
  authorized_networks                = var.authorized_networks
  cluster_resource_labels            = local.common_labels
  node_pools_labels                  = var.node_pools_labels
  node_pools_tags                    = var.node_pools_tags
  identity_namespace                 = var.identity_namespace
  deletion_protection                = var.deletion_protection

  depends_on = [module.vpc]
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = merge(local.common_labels, {
      name = var.argocd_namespace
    })
  }

  depends_on = [module.gke]
}


# ArgoCD Module
module "argocd" {
  source = "../../../modules/argocd-helm"

  namespace                   = kubernetes_namespace.argocd.metadata[0].name
  chart_version              = var.argocd_chart_version
  values_file_path           = var.argocd_values_file_path
  git_repo_url               = var.app_of_apps_repo_url
  git_ssh_private_key        = local.argocd_ssh_key
  create_app_of_apps         = var.create_app_of_apps
  app_of_apps_repo_url       = var.app_of_apps_repo_url
  app_of_apps_repo_revision  = var.app_of_apps_repo_revision
  app_of_apps_path           = var.app_of_apps_path
  additional_applications    = var.additional_applications
  labels                     = local.common_labels

  depends_on = [module.gke, kubernetes_namespace.argocd]
}
