# Company A - Production Environment Configuration Example
# Copy this file to terraform.tfvars and customize the values

# === REQUIRED VARIABLES ===
company     = "company-a"
environment = "production"

gcp_project_id = "multi-tenant-dataloop"
gcp_region     = "us-west1"
gcp_zone       = "us-west1-a"

# === NETWORK CONFIGURATION ===
subnet_cidr    = "10.0.0.0/24"
pods_cidr      = "10.1.0.0/16"
services_cidr  = "10.2.0.0/16"

# Authorized networks for GKE master access (IMPORTANT: Restrict to your IP ranges)
authorized_networks = [
  "5.29.9.128/32"    # Your current IP address
]

# === GKE CLUSTER CONFIGURATION ===
node_machine_type    = "e2-medium"  #e2-medium	     # 2 vCPUs, 4GB RAM - production ready
min_nodes            = 1                # Start with 1 node total (regional)
max_nodes            = 3               # Can scale to 3 nodes later
node_disk_size       = 20              # GB per node
initial_node_count   = 1                # Start with just 1 node initially

# Optional: Use existing service account for GKE nodes
#gke_service_account_email = "gke-nodes@your-project.iam.gserviceaccount.com"

# Security
enable_binary_authorization = true

# === ARGOCD CONFIGURATION ===
# ArgoCD will manage the monitoring stack via GitOps
monitoring_namespace = "monitoring"

# ArgoCD Basic Settings
argocd_chart_version = "5.51.6"
argocd_version      = "v2.9.3"
argocd_service_type = "LoadBalancer"

# ArgoCD Resource Configuration
argocd_server_cpu_request     = "100m"
argocd_server_memory_request  = "128Mi"
argocd_server_cpu_limit       = "500m"
argocd_server_memory_limit    = "512Mi"

argocd_controller_cpu_request    = "250m"
argocd_controller_memory_request = "256Mi"
argocd_controller_cpu_limit      = "500m"
argocd_controller_memory_limit   = "512Mi"

argocd_repo_cpu_request    = "100m"
argocd_repo_memory_request = "128Mi"
argocd_repo_cpu_limit      = "1000m"
argocd_repo_memory_limit   = "1Gi"

# Git Repository Configuration for kube-prometheus-stack
monitoring_repo_url      = "git@github.com:yahav876/multi-tenant-manifest.git"
monitoring_repo_revision = "HEAD"
monitoring_app_path      = "monitoring"

# Disable monitoring app creation initially to avoid circular dependency
create_monitoring_app = false

# SSH key will be provided separately for private repo access
# git_ssh_private_key = "..."  # Add your SSH private key here

# Infrastructure settings - GKE Storage Classes
# ArgoCD will deploy monitoring with persistent storage
storage_class = "standard"     # Will be used by ArgoCD-deployed monitoring stack

# Node selector for workloads (optional)
#node_selector = {
#  "cloud.google.com/gke-nodepool" = "primary-pool"
#}

# === COMMON LABELS ===
common_labels = {
  company     = "company-a"
  environment = "production"
  managed_by  = "terraform"
  team        = "platform"
  cost_center = "engineering"
}

