# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This repository contains a multi-tenant Terraform infrastructure setup for AWS and GCP environments. The current working directory is for Company B's production environment on AWS, which deploys EKS clusters with Karpenter autoscaling.

### Repository Structure

```
multi-tenant/
├── modules/                    # Reusable Terraform modules
│   ├── AWS/
│   │   ├── Compute/
│   │   │   ├── eks-automode/  # EKS Auto Mode with Karpenter
│   │   │   └── eks/           # Standard EKS module
│   │   └── Network/
│   │       └── vpc/           # VPC with EKS-compatible subnets
│   ├── GCP/
│   │   ├── Compute/gcp-gke/   # GKE clusters
│   │   └── Network/gcp-vpc/   # GCP VPC networks
│   └── Helm/
│       ├── Devops-Platform/
│       │   ├── argocd-helm/   # ArgoCD for GitOps
│       │   └── argocd-app-of-apps/
│       └── Monitoring/
│           ├── grafana-helm/
│           └── prometheus-helm/
├── tenants/                   # Tenant-specific configurations
│   ├── company-a/             # GCP-based tenant
│   │   ├── production/
│   │   └── staging/
│   └── company-b/             # AWS-based tenant
│       ├── production/        # Current directory
│       └── staging/
└── providers/                 # Provider configurations
    ├── aws/
    └── gcp/
```

## Development Commands

### Terraform Operations

All Terraform operations should be run from the tenant's environment directory (e.g., `tenants/company-b/production/`).

#### Standard Terraform workflow:
```bash
# Initialize Terraform (run first time or when providers change)
terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy infrastructure (use with caution)
terraform destroy
```

#### Terraform state management:
```bash
# Refresh state to sync with actual infrastructure
terraform refresh

# Show current state
terraform show

# List resources in state
terraform state list

# Force unlock state (if locked)
terraform force-unlock <LOCK_ID>
```

### AWS CLI Operations

#### Update kubeconfig for EKS access:
```bash
# Company B Production
aws eks update-kubeconfig --region us-west-2 --name company-b-production-eks

# Verify connection
kubectl get nodes
```

#### Check EKS cluster status:
```bash
# List EKS clusters
aws eks list-clusters --region us-west-2

# Describe cluster
aws eks describe-cluster --name company-b-production-eks --region us-west-2
```

### Kubernetes Operations

#### Check Karpenter status:
```bash
# Check Karpenter pods
kubectl get pods -n karpenter

# Check NodePools
kubectl get nodepools

# Check EC2NodeClass
kubectl get ec2nodeclasses

# Check nodes provisioned by Karpenter
kubectl get nodes -l karpenter.sh/nodepool
```

#### Deploy applications to specific architectures:
```bash
# Deploy to x86 nodes
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-x86
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-x86
  template:
    metadata:
      labels:
        app: nginx-x86
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
EOF

# Deploy to ARM64/Graviton nodes
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-graviton
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-graviton
  template:
    metadata:
      labels:
        app: nginx-graviton
    spec:
      nodeSelector:
        kubernetes.io/arch: arm64
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
EOF
```

## Key Configuration Files

### Company B Production Environment

- **main.tf**: Main infrastructure configuration with VPC and EKS Auto Mode modules
- **variables.tf**: Variable definitions for all configurable parameters
- **terraform.auto.tfvars**: Environment-specific values including:
  - AWS region (us-west-2)
  - VPC CIDR (10.20.0.0/16)
  - EKS cluster version (1.31)
  - Karpenter node pools configuration
- **provider.tf**: AWS, Helm, and kubectl provider configurations
- **backend.tf**: S3 backend for Terraform state storage
- **outputs.tf**: Output values from modules

### Multi-Tenant Architecture

Each tenant (company-a, company-b) has isolated:
- AWS/GCP accounts and projects
- VPC networks with different CIDR ranges
- Terraform state files in separate S3 buckets
- EKS/GKE clusters with distinct configurations

Company A uses GCP (us-central1) with GKE, while Company B uses AWS (us-west-2) with EKS.

## EKS Auto Mode with Karpenter

### Key Features

1. **EKS Auto Mode**: Automated node provisioning and management
2. **Karpenter**: Advanced autoscaling with mixed instance types
3. **Multi-architecture support**: Both x86 (amd64) and ARM64 (Graviton) nodes
4. **Cost optimization**: Spot instances and ARM64 for 20-40% savings
5. **High availability**: 3 AZs with NAT gateways in each

### Node Pool Configuration

Two primary node pools are configured:
- **x86-nodepool**: AMD64 instances for general workloads
- **graviton-nodepool**: ARM64 instances for cost-optimized workloads

### Karpenter Instance Types

The configuration includes both x86 and ARM64 instance types:
- **x86**: t3.medium-2xlarge, m5.large-4xlarge, c5.large-4xlarge
- **ARM64**: t4g.medium-2xlarge, m6g.large-4xlarge, c6g.large-4xlarge

## Security Considerations

### Network Security
- Private subnets for EKS worker nodes
- Public subnets only for load balancers
- Security groups with least privilege access
- Endpoint access restricted to specific CIDR (5.29.9.128/32)

### Terraform State Security
- S3 backend with versioning enabled
- State files isolated per tenant
- No DynamoDB locking enabled (commented out)

## Common Issues and Solutions

### Terraform State Issues
```bash
# If state is locked
terraform force-unlock <LOCK_ID>

# If state is out of sync
terraform refresh
```

### EKS Access Issues
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name company-b-production-eks

# Check AWS credentials
aws sts get-caller-identity
```

### Karpenter Not Scaling
```bash
# Check Karpenter logs
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter

# Check NodePool events
kubectl describe nodepool <nodepool-name>
```

## Module Dependencies

When modifying modules, be aware of dependencies:
- EKS module depends on VPC module outputs
- Karpenter requires EKS cluster to be created first
- Helm provider depends on EKS cluster endpoint

## Cost Optimization

The configuration is optimized for cost with:
- Spot instances for cost savings
- ARM64 Graviton instances (20-40% cheaper)
- Aggressive node consolidation settings
- Auto-scaling based on actual usage

## Safety Notes
- **Terraform Apply Caution**: 
  - do not run terraform apply , only plan 