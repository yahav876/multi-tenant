# Company A - Production Environment

> **Note**: This README is specific to the `multi-tenant/tenants/company-a/production` directory and its Terraform configuration.

This directory contains Terraform configuration for Company A's production environment on Google Cloud Platform (GCP), implementing a complete multi-tenant Kubernetes platform with GitOps capabilities.

## Architecture Overview

The infrastructure is built using a modular approach with the following key components:

### Infrastructure Components
- **GCP VPC Network** - Dedicated VPC with custom subnets and secondary IP ranges for GKE pods and services
- **GKE Cluster** - Regional Google Kubernetes Engine cluster with auto-scaling node pools
- **ArgoCD** - GitOps continuous deployment tool for application lifecycle management

### Network Architecture
- **Primary Subnet**: `10.0.0.0/24` for node communication
- **Pods Secondary Range**: `10.1.0.0/16` for Kubernetes pods
- **Services Secondary Range**: `10.2.0.0/16` for Kubernetes services
- **Firewall Rules**: Configured for secure access from authorized networks only

## File Structure

```
.
├── backend.tf              # Terraform state configuration (GCS)
├── main.tf                 # Main infrastructure resources
├── provider.tf             # Provider configurations (GCP, Kubernetes, Helm)
├── variables.tf            # Variable definitions
├── terraform.auto.tfvars   # Environment-specific values
├── outputs.tf              # Output definitions
└── README.md              # This file
```

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **Terraform** >= 1.0
- **Google Cloud SDK** (gcloud CLI)
- **kubectl** for Kubernetes cluster management  
- **Helm** >= 3.0 for package management
- Valid **GCP Project** with billing enabled
- **SSH Key** for ArgoCD Git repository access

### Required GCP APIs
Enable the following APIs in your project:
```bash
gcloud services enable compute.googleapis.com \
  container.googleapis.com \
  cloudbuild.googleapis.com \
  --project=multi-tenant-dataloop
```

## Setup Instructions

### 1. Backend Configuration

Create the GCS bucket for Terraform state:
```bash
gsutil mb -p multi-tenant-dataloop -c STANDARD -l us-central1 gs://terraform-state-company-a-production
gsutil versioning set on gs://terraform-state-company-a-production
```

### 2. SSH Key Setup

Ensure your SSH key for ArgoCD Git access is available:
```bash
# Generate if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/argocd_company_a

# Add public key to your Git repository settings
cat ~/.ssh/argocd_company_a.pub
```

### 3. Configuration

Review and update `terraform.auto.tfvars` with your specific values:
- GCP project ID and region
- Network CIDR ranges
- Node pool configurations
- ArgoCD Git repository settings

### 4. Deployment

Initialize and apply the Terraform configuration:

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Post-Deployment Setup

### 1. Kubernetes Access

Configure kubectl to access your new GKE cluster:
```bash
gcloud container clusters get-credentials company-a-production-cluster \
  --region us-west1 \
  --project multi-tenant-dataloop
```

### 2. Install Required CRDs

#### Prometheus Operator CRDs
4. Install CRD's - 
   ```
   for crd in alertmanagerconfigs alertmanagers podmonitors probes prometheusagents prometheuses prometheusrules scrapeconfigs servicemonitors thanosrulers; do
   kubectl create -f "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/kube-prometheus-stack-75.5.0/charts/kube-prometheus-stack/charts/crds/crds/crd-${crd}.yaml"
   done
   ```

#### Cert-Manager CRDs
5. Install cert-manager CRDs:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml
   ```

### 3. ArgoCD Access

Get the ArgoCD admin password and access the UI:
```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI (alternative to LoadBalancer)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at: https://localhost:8080
# Username: admin
# Password: (from command above)
```

## Infrastructure Components Details

### VPC Network
- **Network Name**: `company-a-production-vpc`
- **Routing Mode**: Regional
- **Private Google Access**: Enabled
- **Flow Logs**: Enabled for security monitoring

### GKE Cluster
- **Name**: `company-a-production-cluster`
- **Type**: Regional (High Availability)
- **Node Pool**: `primary-pool` with e2-medium instances
- **Auto-scaling**: 1-3 nodes
- **Features**: Network Policy, VPA, HPA, Shielded Nodes enabled

### Security Configuration
- **Authorized Networks**: Restricted to `5.29.9.128/32`
- **Private Cluster**: Nodes have no external IPs
- **Workload Identity**: Enabled for secure GCP service access
- **Network Policies**: Enabled for pod-to-pod security

### ArgoCD Configuration
- **Version**: 7.1.0
- **Namespace**: `argocd`
- **Git Repository**: Configured for GitOps workflow
- **App of Apps**: Enabled for centralized application management


## Outputs

After successful deployment, Terraform provides:
- Cluster connection information
- ArgoCD access commands
- Network details
- Node pool information

View outputs:
```bash
terraform output
```

## Maintenance & Updates

### Updating Terraform Modules
1. Update version constraints in `provider.tf`
2. Run `terraform plan` to review changes
3. Apply updates with `terraform apply`

### Updating Helm Charts
1. Modify chart versions in `terraform.auto.tfvars`
2. Plan and apply Terraform changes
3. Verify deployments in cluster

### Node Pool Updates
- Auto-upgrades are enabled for security patches
- Manual upgrades can be triggered via Terraform or GCP Console

## Troubleshooting

### Common Issues

**Terraform State Issues**:
```bash
# Refresh state
terraform refresh

# Force unlock if needed
terraform force-unlock <LOCK_ID>
```

**GKE Access Issues**:
```bash
# Ensure proper credentials
gcloud auth application-default login

# Update kubeconfig
gcloud container clusters get-credentials company-a-production-cluster --region us-west1
```

**ArgoCD Connectivity**:
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check service status
kubectl get svc -n argocd
```

## Security Considerations

- **Network Security**: Firewall rules restrict access to authorized IPs only
- **Workload Identity**: Secure service account binding for GCP resources
- **Private Cluster**: Nodes isolated from public internet
- **Secret Management**: Sensitive values stored in Terraform state (consider external secret management)

## Cost Optimization

Current configuration uses:
- `e2-medium` instances for cost-efficiency
- Regional cluster for availability vs cost balance
- Standard persistent disks
- Auto-scaling to minimize idle resources

## Support & Documentation

For additional information:
- [Terraform GKE Module Documentation](../../../modules/gcp-gke/README.md)
- [ArgoCD Module Documentation](../../../modules/argocd-helm/README.md)
- [Company A Infrastructure Documentation](../README.md)

## Version Information

- **Terraform**: ~> 1.0
- **Google Provider**: ~> 6.0  
- **Kubernetes Provider**: ~> 2.24
- **Helm Provider**: ~> 2.12
- **ArgoCD Chart**: 7.1.0