# Prometheus Module

This module deploys Prometheus using the official Helm chart from the Prometheus community. It's designed to be used as part of a monitoring stack for Kubernetes clusters.

## Features

- Deploys Prometheus using the kube-prometheus-stack Helm chart
- Configurable retention period, storage size, and resource requests/limits
- Optional AlertManager deployment
- Customizable node selector for pod placement
- Ability to create a dedicated namespace or use an existing one

## Usage

```hcl
module "prometheus" {
  source = "../../modules/prometheus"

  company     = "example-company"
  environment = "production"
  namespace   = "monitoring"
  
  # Prometheus configuration
  chart_version  = "56.0.0"
  retention      = "30d"
  storage_size   = "50Gi"
  cpu_request    = "500m"
  memory_request = "2Gi"
  cpu_limit      = "2000m"
  memory_limit   = "8Gi"
  
  # Infrastructure configuration
  storage_class = "standard-rwo"
  node_selector = {
    "role" = "monitoring"
  }
  labels = {
    "app" = "prometheus"
  }
  
  # Create namespace
  create_namespace = true
}
```

## Requirements

- Kubernetes cluster
- Helm provider configured
- Kubernetes provider configured
- Storage class available in the cluster

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company | Company identifier | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| namespace | Kubernetes namespace for Prometheus | `string` | `"monitoring"` | no |
| create_namespace | Whether to create the namespace or use an existing one | `bool` | `true` | no |
| chart_version | Version of the kube-prometheus-stack Helm chart | `string` | `"56.0.0"` | no |
| retention | Prometheus data retention period | `string` | `"30d"` | no |
| storage_size | Storage size for Prometheus | `string` | `"50Gi"` | no |
| cpu_request | CPU request for Prometheus | `string` | `"500m"` | no |
| memory_request | Memory request for Prometheus | `string` | `"2Gi"` | no |
| cpu_limit | CPU limit for Prometheus | `string` | `"2000m"` | no |
| memory_limit | Memory limit for Prometheus | `string` | `"8Gi"` | no |
| storage_class | Storage class for persistent volumes | `string` | `"standard-rwo"` | no |
| node_selector | Node selector for pod placement | `map(string)` | `{}` | no |
| labels | Common labels to apply to all resources | `map(string)` | `{}` | no |
| enable_alertmanager | Whether to enable AlertManager | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Kubernetes namespace for Prometheus |
| release_name | Name of the Prometheus Helm release |
| release_status | Status of the Prometheus Helm release |
| chart_version | Version of the Prometheus chart deployed |
| prometheus_url | Internal URL for Prometheus |
