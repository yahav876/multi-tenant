# GCP Load Balancer Controller + Ingress Module

This Terraform module creates a Google Cloud Load Balancer with Kubernetes Ingress for Google Kubernetes Engine (GKE). It provides a production-ready setup for exposing applications with proper security configurations, SSL/TLS termination, and health checks.

## Features

- **GKE Native Integration**: Uses the built-in GKE Ingress controller
- **Static IP Support**: Creates or uses existing static IP addresses
- **SSL/TLS Termination**: Managed SSL certificates with automatic renewal
- **Security**: Cloud Armor integration, firewall rules, IP restrictions
- **Health Checks**: Configurable health check parameters
- **CDN Support**: Optional Cloud CDN integration
- **Session Affinity**: Configurable session affinity options
- **Multi-host/Multi-path**: Support for complex routing rules

## Architecture

This module creates:
1. **Static IP Address**: Global static IP for the load balancer
2. **Managed SSL Certificate**: Google-managed SSL certificates for HTTPS
3. **Kubernetes Ingress**: Main ingress resource with GKE annotations
4. **BackendConfig**: Advanced backend configuration (health checks, timeouts)
5. **FrontendConfig**: Frontend configuration (SSL policies, redirects)
6. **Firewall Rules**: Health check and access control rules

## Prerequisites

- GKE cluster with HTTP load balancing enabled (default)
- VPC-native cluster (recommended for best performance)
- Proper IAM permissions for creating load balancer resources
- Domain name configured to point to the static IP (for SSL certificates)

## Usage

### Basic Example

```hcl
module "grafana_ingress" {
  source = "../../../modules/gcp-lb-ingress"
  
  project_id   = var.gcp_project_id
  name_prefix  = "${var.company}-${var.environment}-grafana"
  namespace    = "monitoring"
  network_name = module.vpc.network_name
  
  # SSL Configuration
  enable_ssl   = true
  ssl_domains  = ["grafana.example.com"]
  allow_http   = false  # HTTPS only
  
  # Ingress Rules
  ingress_rules = [
    {
      host = "grafana.example.com"
      paths = [
        {
          path         = "/*"
          path_type    = "ImplementationSpecific"
          service_name = "grafana"
          service_port = 80
        }
      ]
    }
  ]
  
  # Security
  authorized_source_ranges = ["5.29.9.128/32"]  # Your IP
  target_tags             = ["gke-node"]
  
  # Labels
  labels = {
    company     = var.company
    environment = var.environment
    app         = "grafana"
  }
}
```

### Advanced Example with Multiple Services

```hcl
module "app_ingress" {
  source = "../../../modules/gcp-lb-ingress"
  
  project_id   = var.gcp_project_id
  name_prefix  = "${var.company}-${var.environment}-apps"
  namespace    = "services"
  network_name = module.vpc.network_name
  
  # SSL Configuration
  enable_ssl   = true
  ssl_domains  = ["app.example.com", "api.example.com"]
  
  # Multiple hosts and paths
  ingress_rules = [
    {
      host = "app.example.com"
      paths = [
        {
          path         = "/*"
          path_type    = "ImplementationSpecific"
          service_name = "frontend"
          service_port = 80
        }
      ]
    },
    {
      host = "api.example.com"
      paths = [
        {
          path         = "/api/*"
          path_type    = "ImplementationSpecific"
          service_name = "backend-api"
          service_port = 8080
        },
        {
          path         = "/health"
          path_type    = "Exact"
          service_name = "health-service"
          service_port = 8080
        }
      ]
    }
  ]
  
  # Advanced Backend Configuration
  create_backend_config = true
  backend_timeout       = 60
  session_affinity_type = "CLIENT_IP"
  
  # Health Check Configuration
  health_check_path     = "/health"
  health_check_port     = 8080
  health_check_interval = 10
  
  # CDN Configuration
  enable_cdn = true
  
  # Security
  authorized_source_ranges = ["5.29.9.128/32"]
  security_policy_name     = "my-security-policy"
  
  labels = {
    company     = var.company
    environment = var.environment
    tier        = "application"
  }
}
```

### Internal Load Balancer Example

```hcl
module "internal_ingress" {
  source = "../../../modules/gcp-lb-ingress"
  
  project_id         = var.gcp_project_id
  name_prefix        = "${var.company}-${var.environment}-internal"
  namespace          = "internal"
  network_name       = module.vpc.network_name
  load_balancer_type = "Internal"
  
  # No SSL for internal services
  enable_ssl = false
  allow_http = true
  
  ingress_rules = [
    {
      host = "internal.example.com"
      paths = [
        {
          path         = "/*"
          path_type    = "ImplementationSpecific"
          service_name = "internal-service"
          service_port = 80
        }
      ]
    }
  ]
  
  # Internal network access only
  authorized_source_ranges = ["10.0.0.0/16"]
  
  labels = {
    company     = var.company
    environment = var.environment
    visibility  = "internal"
  }
}
```

## Important Notes

### SSL Certificate Activation
- SSL certificates take 15-20 minutes to become active
- Domain must be pointing to the static IP before certificate activation
- Certificate status can be checked via Google Cloud Console

### Firewall Rules
The module creates two types of firewall rules:
1. **Health Check Rule**: Allows Google Cloud health checks (130.211.0.0/22, 35.191.0.0/16)
2. **Access Rule**: Allows traffic from authorized source ranges

### IP Address Management
- Static IP addresses are not deleted when the module is destroyed
- Clean up static IPs manually if no longer needed to avoid charges

### GKE Ingress Controller
This module uses the built-in GKE Ingress controller (`gce` or `gce-internal`), which:
- Automatically creates Google Cloud Load Balancer resources
- Supports container-native load balancing (recommended)
- Integrates with GCP services (Cloud Armor, Cloud CDN, etc.)

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `project_id` | The GCP project ID | `string` |
| `name_prefix` | Prefix for naming resources | `string` |
| `namespace` | Kubernetes namespace | `string` |
| `network_name` | Name of the VPC network | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_static_ip` | Create a new static IP | `bool` | `true` |
| `enable_ssl` | Enable SSL/TLS | `bool` | `true` |
| `ssl_domains` | Domains for SSL certificates | `list(string)` | `[]` |
| `load_balancer_type` | External or Internal | `string` | `External` |
| `allow_http` | Allow HTTP traffic | `bool` | `false` |
| `authorized_source_ranges` | Authorized IP ranges | `list(string)` | `[]` |
| `target_tags` | Target tags for firewall | `list(string)` | `["gke-node"]` |

See `variables.tf` for complete list of variables.

## Outputs

| Name | Description |
|------|-------------|
| `ingress_ip` | External IP of the load balancer |
| `static_ip_address` | Static IP address |
| `ssl_certificate_name` | SSL certificate name |
| `ingress_name` | Name of the ingress resource |

See `outputs.tf` for complete list of outputs.

## Best Practices

1. **Use HTTPS Only**: Set `allow_http = false` for production
2. **Restrict Access**: Use `authorized_source_ranges` to limit access
3. **Health Checks**: Configure appropriate health check paths
4. **Resource Naming**: Use consistent `name_prefix` for resource organization
5. **Labels**: Apply comprehensive labels for resource management
6. **Static IPs**: Use static IPs for production services
7. **SSL Domains**: Ensure domains point to the static IP before applying

## Troubleshooting

### Common Issues

1. **SSL Certificate Not Active**
   - Verify domain points to static IP
   - Wait 15-20 minutes for activation
   - Check certificate status in GCP Console

2. **502 Bad Gateway**
   - Verify service exists and is healthy
   - Check health check configuration
   - Ensure proper backend configuration

3. **Firewall Issues**
   - Verify authorized source ranges
   - Check that target tags match node tags
   - Ensure health check firewall rule exists

4. **Ingress IP Not Assigned**
   - Wait for load balancer provisioning (5-10 minutes)
   - Check GKE cluster has HTTP load balancing enabled
   - Verify proper annotations on ingress

### Useful Commands

```bash
# Check ingress status
kubectl get ingress -n <namespace>

# Check ingress details
kubectl describe ingress <ingress-name> -n <namespace>

# Check SSL certificate status
gcloud compute ssl-certificates describe <cert-name> --global

# Check static IP
gcloud compute addresses describe <ip-name> --global

# Check load balancer
gcloud compute url-maps list
```

## Integration with Grafana

To use this module with your existing Grafana setup:

1. **Update Grafana Service**: Ensure your Grafana service uses `ClusterIP` (not `LoadBalancer`)
2. **Configure Health Check**: Set up a health check endpoint in Grafana
3. **Apply Ingress**: Use this module to create the ingress
4. **Update DNS**: Point your domain to the static IP

## Migration from LoadBalancer Service

If migrating from a `LoadBalancer` service:

1. **Create the ingress** using this module
2. **Update service type** from `LoadBalancer` to `ClusterIP`
3. **Update DNS** to point to the new static IP
4. **Test the setup** before removing old load balancer

## License

This module is provided as-is for educational and production use.