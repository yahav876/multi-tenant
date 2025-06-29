# EKS Auto Mode Module with Karpenter

This module creates an Amazon EKS cluster with EKS Auto Mode enabled and optionally installs Karpenter for advanced node autoscaling.

## Features

- **EKS Auto Mode**: Leverages AWS's automatic node management capabilities
- **Karpenter Integration**: Optional Karpenter installation for flexible autoscaling
- **Multi-Architecture Support**: Default NodePool supports both x86_64 (amd64) and ARM64 architectures
- **Cost Optimization**: Supports both Spot and On-Demand instances
- **Security**: Includes IRSA setup, EBS CSI driver, and security best practices

## Usage

```hcl
module "eks_auto_mode" {
  source = "../../../modules/AWS/Compute/eks-automode"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # EKS Auto Mode configuration
  eks_auto_mode_node_pools = [
    {
      name = "system"
      instance_types = ["t3.medium"]
      scaling_config = {
        min_size     = 2
        max_size     = 4
        desired_size = 2
      }
    }
  ]

  # Enable Karpenter
  enable_karpenter = true
  
  # Karpenter configuration
  karpenter_instance_types = [
    # x86_64 instances
    "t3.medium", "t3.large", "t3.xlarge",
    "m5.large", "m5.xlarge",
    # ARM64 instances
    "t4g.medium", "t4g.large", "t4g.xlarge",
    "m6g.large", "m6g.xlarge"
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Multi-Architecture Support

The default Karpenter NodePool is configured to support both x86_64 and ARM64 architectures. This allows you to:

1. **Run mixed workloads**: Deploy applications optimized for either architecture
2. **Cost optimization**: ARM64 instances often provide better price/performance
3. **Flexibility**: Let Karpenter choose the best instance type based on workload requirements

### Deploying Architecture-Specific Workloads

To deploy workloads on specific architectures, use node selectors:

```yaml
# For x86_64 workloads
nodeSelector:
  kubernetes.io/arch: amd64

# For ARM64 workloads
nodeSelector:
  kubernetes.io/arch: arm64
```

## Karpenter Configuration

### Default NodePool

The module creates a default NodePool with:
- Support for both Spot and On-Demand instances
- Mixed architecture support (x86_64 and ARM64)
- Configurable instance types
- Automatic consolidation and expiration policies

### Custom NodePools

You can disable the default NodePool and create your own:

```hcl
create_default_karpenter_node_pool = false
```

Then apply your custom NodePool manifests after the cluster is created.

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- kubectl provider (for Karpenter manifests)
- helm provider (for Karpenter installation)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the EKS cluster | string | - | yes |
| cluster_version | Kubernetes version | string | "1.31" | no |
| vpc_id | VPC ID | string | - | yes |
| subnet_ids | List of subnet IDs | list(string) | - | yes |
| enable_karpenter | Enable Karpenter | bool | true | no |
| karpenter_instance_types | Instance types for Karpenter | list(string) | See variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Kubernetes API endpoint |
| cluster_certificate_authority_data | Certificate for cluster access |
| karpenter_iam_role_arn | Karpenter controller IAM role |
| update_kubeconfig_command | Command to update kubeconfig |

## Post-Deployment

After deploying the cluster:

1. Update your kubeconfig:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

2. Verify Karpenter is running:
   ```bash
   kubectl get pods -n karpenter
   ```

3. Check the default NodePool:
   ```bash
   kubectl get nodepool
   kubectl get ec2nodeclass
   ```

4. Deploy a test workload to see autoscaling in action:
   ```bash
   kubectl apply -f - <<EOF
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: inflate
   spec:
     replicas: 0
     selector:
       matchLabels:
         app: inflate
     template:
       metadata:
         labels:
           app: inflate
       spec:
         containers:
         - name: inflate
           image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
           resources:
             requests:
               cpu: 1
   EOF
   
   # Scale up to trigger Karpenter
   kubectl scale deployment inflate --replicas=10
   ```
