# === COMMON LABELS ===
common_labels = {
  company     = "company-a"
  environment = "production"
  managed_by  = "terraform"
  team        = "platform"
  cost_center = "engineering"
}

# === GCP CONFIGURATION ===
gcp_project_id = "multi-tenant-dataloop"
gcp_region     = "us-west1"
gcp_zone       = "us-west1-a"

# === VPC CONFIGURATION ===
vpc_network_name            = "company-a-production-vpc"
vpc_routing_mode           = "REGIONAL"
vpc_subnet_name            = "company-a-production-subnet"
subnet_cidr                = "10.0.0.0/24"
vpc_subnet_private_access  = true
vpc_subnet_flow_logs       = true
vpc_subnet_description     = "Primary subnet for company-a production"
vpc_pods_range_name        = "gke-pods"
pods_cidr                  = "10.1.0.0/16"
vpc_services_range_name    = "gke-services"
services_cidr              = "10.2.0.0/16"

# Firewall rules for GKE - matching existing rules
vpc_ingress_rules = [
  {
    name        = "company-a-production-allow-https"
    description = "Allow HTTPS from authorized networks"
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["5.29.9.128/32"]
    source_tags = []
    target_tags = ["gke-node"]
    allow = [{
      protocol = "tcp"
      ports    = ["443"]
    }]
    deny = []
  },
  {
    name        = "company-a-production-allow-internal"
    description = "Allow internal communication within VPC"
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["10.0.0.0/24", "10.1.0.0/16", "10.2.0.0/16"]
    source_tags = []
    target_tags = ["gke-node"]
    allow = [
      {
        protocol = "tcp"
        ports    = ["0-65535"]
      },
      {
        protocol = "udp"
        ports    = ["0-65535"]
      },
      {
        protocol = "icmp"
        ports    = []
      }
    ]
    deny = []
  },
  {
    name        = "company-a-production-allow-ssh"
    description = "Allow SSH from authorized networks"
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["5.29.9.128/32"]
    source_tags = []
    target_tags = ["gke-node"]
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
  }
]

# === GKE CONFIGURATION ===
cluster_name                       = "company-a-production-cluster"
regional                          = true
remove_default_node_pool          = true
initial_node_count                = 1
network_policy                    = true
horizontal_pod_autoscaling        = true
enable_vertical_pod_autoscaling   = true
enable_shielded_nodes             = true
enable_binary_authorization       = false  # Set to false for easier initial setup
logging_service                   = "logging.googleapis.com/kubernetes"
monitoring_service                = "monitoring.googleapis.com/kubernetes"
authorized_networks               = ["5.29.9.128/32"]  # Restrict this for production
identity_namespace                = "multi-tenant-dataloop.svc.id.goog"
deletion_protection               = false

# Node pools configuration
node_pools = [
  {
    name               = "primary-pool"
    machine_type       = "e2-medium"
    min_count          = 1
    max_count          = 3
    local_ssd_count    = 0
    spot               = false
    disk_size_gb       = 20
    disk_type          = "pd-standard"
    image_type         = "COS_CONTAINERD"
    enable_gcfs        = false
    enable_gvnic       = false
    auto_repair        = true
    auto_upgrade       = true
    service_account    = ""  # Will use default compute service account
    preemptible        = false
    initial_node_count = 1
  }
]

node_pools_labels = {
  primary-pool = {
    env  = "production"
    team = "platform"
  }
}

node_pools_tags = {
  primary-pool = ["gke-node", "company-a-production"]
}



# ArgoCD Helm Chart version
argocd_chart_version = "7.1.0"

# Path to your SSH key on your local machine (should be readable by Terraform)
argocd_ssh_private_key_path = "/home/youruser/.ssh/id_rsa_argocd"

# ArgoCD will track this Git repo for manifests
argocd_git_repo_url = "git@github.com:yahav876/multi-tenant-manifest.git"

# No need to set values_file_path (use module default templating)
# values_file_path = ""

# App of Apps settings (optional)
create_app_of_apps = true
app_of_apps_repo_url = "git@github.com:yahav876/multi-tenant-manifest.git"
app_of_apps_repo_revision = "HEAD"
app_of_apps_path = "."
additional_applications = []

# # === ARGOCD CONFIGURATION ===
# argocd_namespace      = "argocd"
# argocd_chart_version = "5.46.7"

# # === APP OF APPS CONFIGURATION ===
# # Enable App of Apps pattern for better GitOps management
# create_app_of_apps = true
# app_of_apps_repo_url = "git@github.com:yahav876/multi-tenant-manifest.git"
# app_of_apps_repo_revision = "HEAD"
# app_of_apps_path = "applications/company-a/production"

# # === ADDITIONAL APPLICATIONS ===
# # Define additional applications that ArgoCD should manage
# additional_applications = [
#   {
#     name           = "sample-app"
#     namespace      = "argocd"
#     repo_url       = "git@github.com:yahav876/multi-tenant-manifest.git"
#     target_revision = "HEAD"
#     path           = "applications/sample-app"
#     dest_namespace = "services"
#     project        = "default"
#   },
#   {
#     name           = "monitoring"
#     namespace      = "argocd"
#     repo_url       = "git@github.com:yahav876/multi-tenant-manifest.git"
#     target_revision = "HEAD"
#     path           = "monitoring"
#     dest_namespace = "monitoring"
#     project        = "default"
#     sync_policy = {
#       automated = {
#         prune       = true
#         self_heal   = true
#         allow_empty = false
#       }
#       sync_options = [
#         "CreateNamespace=true",
#         "PrunePropagationPolicy=foreground",
#         "PruneLast=true",
#         "ServerSideApply=true"
#       ]
#     }
#   }
# ]
