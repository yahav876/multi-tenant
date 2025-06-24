# Company A - Production Environment

This directory contains Terraform configuration for Company A's production environment, which includes:

- GKE (Google Kubernetes Engine) cluster
- VPC networking with proper subnets for GKE
- Monitoring stack with Prometheus and Grafana

## Architecture

The infrastructure is built using the following components:

1. **GCP VPC** - A dedicated VPC network with subnets configured for GKE
2. **GKE Cluster** - A regional GKE cluster for high availability
3. **Monitoring Stack** - Prometheus and Grafana deployed via Helm charts

## Prerequisites

- Terraform >= 1.0
- Google Cloud SDK
- kubectl
- Helm

## Provider Configuration

This environment uses a provider configuration based on the pattern from `providers/gcp/provider.tf`. The provider configuration is defined in `provider.tf` and follows the same pattern as the central provider configuration to ensure consistency across all environments.

## Setup Instructions

1. Update the `terraform.tfvars` file with your specific values:
   - Set your GCP project ID
   - Configure a secure Grafana admin password
   - Adjust the authorized networks to your specific IP ranges
   - Create backend with - gsutil mb -p multi-tenant-dataloop -c STANDARD -l us-central1 gs://terraform-state-company-a-production
   - gcloud services enable compute.googleapis.com container.googleapis.com --project=multi-tenant-dataloop



2. Initialize Terraform:
   ```
   terraform init
   ```

3. Plan the deployment:
   ```
   terraform plan
   ```

4. Apply the configuration:
   ```
   terraform apply
   ```

## Accessing the Environment

### GKE Cluster

After deployment, you can configure kubectl to access the GKE cluster:

```
gcloud container clusters get-credentials company-a-production-cluster --region us-central1 --project your-gcp-project-id
```

### Grafana

Grafana is deployed with a LoadBalancer service. You can access it at:

```
kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Use the configured admin username and password to log in.

### Prometheus

Prometheus is not exposed externally by default. To access it, you can use port-forwarding:

```
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Then access Prometheus at http://localhost:9090

## Customization

To customize the deployment:

1. Modify `terraform.tfvars` for basic configuration changes
2. For more advanced changes, modify the modules or create new ones

## Maintenance

### Updating Helm Charts

To update the Helm charts to newer versions:

1. Update the chart version variables in `terraform.tfvars`
2. Run `terraform plan` to see the changes
3. Apply the changes with `terraform apply`
4. Install CRD's - 
   ```
   for crd in alertmanagerconfigs alertmanagers podmonitors probes prometheusagents prometheuses prometheusrules scrapeconfigs servicemonitors thanosrulers; do
   kubectl create -f "https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/tags/kube-prometheus-stack-75.5.0/charts/kube-prometheus-stack/charts/crds/crds/crd-${crd}.yaml"
   done
   ```