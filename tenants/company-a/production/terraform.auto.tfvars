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
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# === VPC CONFIGURATION ===
vpc_network_name            = "company-a-prod-vpc"
vpc_routing_mode           = "REGIONAL"
vpc_subnet_name            = "company-a-prod-subnet"
subnet_cidr                = "10.0.0.0/16"
vpc_subnet_private_access  = true
vpc_subnet_flow_logs       = true
vpc_subnet_description     = "Primary subnet for Company A production environment"
vpc_pods_range_name        = "pods-range"
pods_cidr                  = "10.1.0.0/16"
vpc_services_range_name    = "services-range"
services_cidr              = "10.2.0.0/16"

# Firewall rules for GKE
vpc_ingress_rules = [
  {
    name        = "allow-gke-ingress"
    description = "Allow ingress traffic for GKE"
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["10.0.0.0/8"]
    source_tags = []
    target_tags = ["gke-nodes"]
    allow = [{
      protocol = "tcp"
      ports    = ["443", "80", "8080", "9090", "3000"]
    }]
    deny = []
  }
]

# === GKE CONFIGURATION ===
cluster_name                       = "company-a-prod-gke"
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
authorized_networks               = ["0.0.0.0/0"]  # Restrict this for production
identity_namespace                = "multi-tenant-dataloop.svc.id.goog"
deletion_protection               = false

# Node pools configuration
node_pools = [
  {
    name               = "default-pool"
    machine_type       = "e2-medium"
    min_count          = 1
    max_count          = 3
    local_ssd_count    = 0
    spot               = false
    disk_size_gb       = 30
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
  default-pool = {
    env  = "production"
    team = "platform"
  }
}

node_pools_tags = {
  default-pool = ["gke-nodes", "production"]
}

# === ARGOCD CONFIGURATION ===
argocd_namespace      = "argocd"
argocd_chart_version = "5.46.7"

# === APP OF APPS CONFIGURATION ===
# Enable App of Apps pattern for better GitOps management
create_app_of_apps = true
app_of_apps_repo_url = "git@github.com:yahav876/multi-tenant-manifest.git"
app_of_apps_repo_revision = "HEAD"
app_of_apps_path = "applications/company-a/production"

# === ADDITIONAL APPLICATIONS ===
# Define additional applications that ArgoCD should manage
additional_applications = [
  {
    name           = "sample-app"
    namespace      = "argocd"
    repo_url       = "git@github.com:yahav876/multi-tenant-manifest.git"
    target_revision = "HEAD"
    path           = "applications/sample-app"
    dest_namespace = "services"
    project        = "default"
  }
  # Add more applications as needed
  # {
  #   name           = "another-app"
  #   namespace      = "argocd"
  #   repo_url       = "git@github.com:yahav876/multi-tenant-manifest.git"
  #   target_revision = "HEAD"
  #   path           = "applications/another-app"
  #   dest_namespace = "services"
  #   project        = "default"
  # }
]
