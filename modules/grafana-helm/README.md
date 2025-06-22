# Grafana Module

This module deploys Grafana using the official Helm chart from Grafana Labs. It's designed to be used as part of a monitoring stack for Kubernetes clusters, typically alongside Prometheus.

## Features

- Deploys Grafana using the official Grafana Helm chart
- Configurable admin credentials
- Persistent storage for dashboards and settings
- Customizable resource requests/limits
- LoadBalancer service for external access
- Pre-configured Prometheus data source
- Default Kubernetes dashboards
- Customizable node selector for pod placement
- Ability to create a dedicated namespace or use an existing one

## Usage

```hcl
module "grafana" {
  source = "../../modules/grafana"

  company     = "example-company"
  environment = "production"
  namespace   = "monitoring"
  
  # Grafana configuration
  chart_version  = "7.3.0"
  admin_user     = "admin"
  admin_password = "secure-password"
  storage_size   = "10Gi"
  cpu_request    = "100m"
  memory_request = "128Mi"
  cpu_limit      = "500m"
  memory_limit   = "1Gi"
  
  # Infrastructure configuration
  storage_class      = "standard-rwo"
  node_selector      = {
    "role" = "monitoring"
  }
  load_balancer_type = "Internal"
  labels             = {
    "app" = "grafana"
  }
  
  # Connect to Prometheus
  prometheus_url = "http://prometheus-server.monitoring.svc.cluster.local:9090"
  
  # Don't create namespace, use existing
  create_namespace = false
}
```

## Requirements

- Kubernetes cluster
- Helm provider configured
- Kubernetes provider configured
- Storage class available in the cluster
- Prometheus deployment (for data source)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company | Company identifier | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| namespace | Kubernetes namespace for Grafana | `string` | `"monitoring"` | no |
| create_namespace | Whether to create the namespace or use an existing one | `bool` | `false` | no |
| chart_version | Version of the Grafana Helm chart | `string` | `"7.3.0"` | no |
| admin_user | Grafana admin username | `string` | `"admin"` | no |
| admin_password | Grafana admin password | `string` | n/a | yes |
| storage_size | Storage size for Grafana | `string` | `"10Gi"` | no |
| cpu_request | CPU request for Grafana | `string` | `"100m"` | no |
| memory_request | Memory request for Grafana | `string` | `"128Mi"` | no |
| cpu_limit | CPU limit for Grafana | `string` | `"500m"` | no |
| memory_limit | Memory limit for Grafana | `string` | `"1Gi"` | no |
| storage_class | Storage class for persistent volumes | `string` | `"standard-rwo"` | no |
| node_selector | Node selector for pod placement | `map(string)` | `{}` | no |
| load_balancer_type | Load balancer type for Grafana service | `string` | `"Internal"` | no |
| labels | Common labels to apply to all resources | `map(string)` | `{}` | no |
| prometheus_url | URL of the Prometheus server to use as a data source | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Kubernetes namespace for Grafana |
| release_name | Name of the Grafana Helm release |
| release_status | Status of the Grafana Helm release |
| chart_version | Version of the Grafana chart deployed |
| admin_user | Grafana admin username |
| service_info | Information about accessing Grafana |
