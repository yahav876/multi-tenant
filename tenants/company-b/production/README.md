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

## Outputs

After applying, the following outputs will be available:
- `vpc_id` - The ID of the created VPC
- `vpc_cidr` - The CIDR block of the VPC
- `private_subnet_ids` - List of private subnet IDs
- `public_subnet_ids` - List of public subnet IDs
- `availability_zones` - List of availability zones used

## Important Notes

1. The VPC is configured with EKS-compatible tags for future Kubernetes deployments
2. NAT Gateways are deployed in each AZ for high availability (production best practice)
3. The CIDR range (10.20.0.0/16) is chosen to avoid conflicts with other environments

## Cost Considerations

- 3 NAT Gateways (one per AZ) will incur charges
- Consider using a single NAT Gateway for non-critical environments to reduce costs

## Next Steps

After the VPC is created, you can:
1. Deploy an EKS cluster using the Compute modules
2. Set up monitoring with Prometheus and Grafana
3. Configure additional security groups and network ACLs as needed
