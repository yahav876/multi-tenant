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
- **Features**:
  - 3 Availability Zones for high availability
  - 3 Private subnets (10.20.1.0/24, 10.20.2.0/24, 10.20.3.0/24)
  - 3 Public subnets (10.20.101.0/24, 10.20.102.0/24, 10.20.103.0/24)
  - NAT Gateway in each AZ for high availability
  - EKS-ready subnet tagging

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
