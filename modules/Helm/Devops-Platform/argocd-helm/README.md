# ArgoCD Helm Module

This module deploys ArgoCD using the official Helm chart and optionally creates an ArgoCD Application for the kube-prometheus-stack.

## Features

- Deploys ArgoCD using the official Argo Helm chart
- Configurable resource requests and limits
- Support for ingress configuration
- Automatic creation of monitoring application
- SSH key management for private Git repositories
- High availability configuration options

## Usage

```hcl
module "argocd" {
  source = "../../../modules/argocd-helm"

  # Basic configuration
  namespace    = "argocd"
  chart_version = "5.51.6"
  
  # Git repository configuration
  git_repo_url           = "git@github.com:yahav876/multi-tenant-manifest.git"
  monitoring_repo_url    = "git@github.com:yahav876/multi-tenant-manifest.git"
  monitoring_app_path    = "monitoring"
  
  # Resource configuration
  server_cpu_request    = "100m"
  server_memory_request = "128Mi"
  
  # Labels
  labels = {
    company     = "example"
    environment = "production"
  }
}
```

## Accessing ArgoCD

1. Get the admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
   ```

2. Port-forward to access the UI:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. Open https://localhost:8080 and login with:
   - Username: `admin`
   - Password: (from step 1)

## Monitoring Application

The module can automatically create an ArgoCD Application that monitors your Git repository for kube-prometheus-stack manifests. Set `create_monitoring_app = true` and configure the Git repository settings.

## Requirements

- Kubernetes cluster
- Helm provider configured
- Kubernetes provider configured

## Inputs

See `variables.tf` for all available inputs.

## Outputs

See `outputs.tf` for all available outputs.
