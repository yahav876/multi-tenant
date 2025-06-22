# Company A - Production Environment Configuration Example
# Copy this file to terraform.tfvars and customize the values

# === REQUIRED VARIABLES ===
company     = "company-a"
environment = "production"

gcp_project_id = "multi-tenant-dataloop"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# === NETWORK CONFIGURATION ===
subnet_cidr    = "10.0.0.0/24"
pods_cidr      = "10.1.0.0/16"
services_cidr  = "10.2.0.0/16"

# Authorized networks for GKE master access (IMPORTANT: Restrict to your IP ranges)
authorized_networks = [
  "203.0.113.0/24",  # Example: Your office network
  "198.51.100.0/24"  # Example: Your VPN network
]

# === GKE CLUSTER CONFIGURATION ===
node_machine_type    = "e2-standard-4"  # 4 vCPUs, 16GB RAM - production ready
min_nodes            = 3                # Minimum nodes for HA
max_nodes            = 10               # Maximum nodes for scaling
node_disk_size       = 100              # GB per node
initial_node_count   = 3                # Starting number of nodes

# Optional: Use existing service account for GKE nodes
#gke_service_account_email = "gke-nodes@your-project.iam.gserviceaccount.com"

# Security
enable_binary_authorization = true

# === MONITORING CONFIGURATION ===
monitoring_namespace = "monitoring"

# Prometheus settings
prometheus_chart_version  = "56.0.0"
prometheus_retention      = "30d"
prometheus_storage_size   = "50Gi"
prometheus_cpu_request    = "500m"
prometheus_memory_request = "2Gi"
prometheus_cpu_limit      = "2000m"
prometheus_memory_limit   = "8Gi"

# Grafana settings
grafana_chart_version   = "7.3.0"
grafana_admin_user      = "admin"
grafana_admin_password  = "secure-password-123"  # Use a strong password!
grafana_storage_size    = "10Gi"
grafana_cpu_request     = "100m"
grafana_memory_request  = "128Mi"
grafana_cpu_limit       = "500m"
grafana_memory_limit    = "1Gi"

# Infrastructure settings
storage_class      = "standard-rwo"
load_balancer_type = "Internal"  # Use "External" for public access

# Node selector for monitoring workloads (optional)
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

