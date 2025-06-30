# Company B - Production Environment

This directory contains the Terraform configuration for Company B's production infrastructure on AWS.

## Overview

- **Company**: Company B
- **Environment**: Production
- **AWS Region**: us-west-2
- **VPC CIDR**: 10.20.0.0/16

## Infrastructure Components

### VPC (Virtual Private Cloud)
- **Module**: `../../../modules/AWS/Network/vpc`
### EKS (Auto-Mode)
- **Module**: `../../../modules/AWS/Compute/eks-automode`

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0
3. S3 bucket for Terraform state (terraform-state-company-b-production)
4. DynamoDB table for state locking (terraform-locks-company-b)

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Deploy applications to specific architectures:

   After the infrastructure is deployed, developers can deploy applications to specific node architectures based on the custom NodePools defined in terraform.tfvars.

   **Update kubeconfig first:**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name company-b-production-eks
   ```

   **Method 1: Using NodeSelector (Recommended)**
   ```yaml
   # nginx-x86-deployment.yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-x86
     namespace: default
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
         # Schedule on x86 nodes using Kubernetes standard label
         nodeSelector:
           kubernetes.io/arch: amd64  # Standard k8s label (automatic)
           # OR use our custom label from Karpenter NodePool:
           # arch-type: x86
         containers:
         - name: nginx
           image: nginx:latest
           ports:
           - containerPort: 80
           resources:
             requests:
               cpu: "100m"
               memory: "128Mi"
             limits:
               cpu: "500m"
               memory: "512Mi"
   ```

   **Method 2: Using Karpenter Requirements (Pod Affinity)**
   ```yaml
   # nginx-graviton-deployment.yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-graviton
     namespace: default
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
         # Using node affinity for more complex requirements
         affinity:
           nodeAffinity:
             requiredDuringSchedulingIgnoredDuringExecution:
               nodeSelectorTerms:
               - matchExpressions:
                 - key: kubernetes.io/arch
                   operator: In
                   values: ["arm64"]
                 - key: karpenter.sh/nodepool
                   operator: In
                   values: ["graviton-nodepool"]
         containers:
         - name: nginx
           image: nginx:latest  
           ports:
           - containerPort: 80
           resources:
             requests:
               cpu: "100m"
               memory: "128Mi"
             limits:
               cpu: "500m"
               memory: "512Mi"
   ```


   **Deploy the application:**
   ```bash
   # For x86 deployment
   kubectl apply -f nginx-x86-deployment.yaml

   # For Graviton deployment
   kubectl apply -f nginx-graviton-deployment.yaml


## Configuration Files

- `main.tf` - Main Terraform configuration with module calls
- `variables.tf` - Variable definitions
- `terraform.auto.tfvars` - Variable values for this environment
- `provider.tf` - AWS provider configuration
- `backend.tf` - Remote state configuration
- `outputs.tf` - Output values from modules

## Important Notes

1. The VPC is configured with EKS-compatible tags for future Kubernetes deployments
2. NAT Gateways are deployed in each AZ for high availability (production best practice)
