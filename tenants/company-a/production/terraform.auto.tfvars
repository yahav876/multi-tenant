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

# === MONITORING CONFIGURATION ===
monitoring_namespace = "monitoring"

# Prometheus settings
prometheus_chart_version  = "56.0.0"
prometheus_retention      = "30d"
prometheus_storage_size   = "10Gi"
prometheus_cpu_request    = "100m"
prometheus_memory_request = "128Mi"
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

# Infrastructure settings - GKE Storage Classes
# NOTE: Existing PVCs use "standard" - changing requires manual migration
# GKE provides these storage classes by default:
# - "standard" - Standard persistent disk (HDD) - CURRENTLY USED
# - "standard-rwo" - Standard persistent disk (HDD) with ReadWriteOnce  
# - "premium-rwo" - SSD persistent disk with ReadWriteOnce (recommended for new deployments)
# - "fast-ssd" - Custom fast SSD class (created by our Terraform)
# - "balanced-ssd" - Custom balanced SSD class (created by our Terraform)
storage_class      = "standard"     # Keep existing for now - migration required for change
load_balancer_type = "Internal"     # Use "External" for public access

# To migrate to SSD storage:
# 1. Backup data: kubectl exec -n monitoring deployment/grafana -- tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana
# 2. Delete PVC: kubectl delete pvc grafana -n monitoring
# 3. Change storage_class to "premium-rwo" here
# 4. Apply: tofu apply
# 5. Restore data if needed

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

