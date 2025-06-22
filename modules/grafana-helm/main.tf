# Grafana Module using Helm Provider
# Deploys Grafana using official Helm charts

# Create monitoring namespace if it doesn't exist
resource "kubernetes_namespace" "monitoring" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      company     = var.company
      environment = var.environment
      purpose     = "monitoring"
    }
  }
}

# Deploy Grafana separately for better control
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.chart_version
  namespace  = var.create_namespace ? kubernetes_namespace.monitoring[0].metadata[0].name : var.namespace

  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      # Admin credentials
      adminUser     = var.admin_user
      adminPassword = var.admin_password
      
      # Persistence - Keep simple for existing deployments
      persistence = {
        enabled          = true
        storageClassName = var.storage_class
        size             = var.storage_size
        accessModes      = ["ReadWriteOnce"]
      }
      
      # Service configuration
      service = {
        type = "LoadBalancer"
        annotations = {
          "cloud.google.com/load-balancer-type" = var.load_balancer_type
        }
      }
      
      # Resources
      resources = {
        requests = {
          cpu    = var.cpu_request
          memory = var.memory_request
        }
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
      
      # Node selector
      nodeSelector = var.node_selector
      
      # Datasources - connect to Prometheus
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [{
            name      = "Prometheus"
            type      = "prometheus"
            url       = var.prometheus_url
            access    = "proxy"
            isDefault = true
          }]
        }
      }
      
      # Dashboard providers
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [{
            name            = "default"
            orgId           = 1
            folder          = ""
            type            = "file"
            disableDeletion = false
            editable        = true
            options = {
              path = "/var/lib/grafana/dashboards/default"
            }
          }]
        }
      }
      
      # Import default Kubernetes dashboards
      dashboards = {
        default = {
          kubernetes-cluster = {
            gnetId     = 7249
            revision   = 1
            datasource = "Prometheus"
          }
          kubernetes-nodes = {
            gnetId     = 1860
            revision   = 1
            datasource = "Prometheus"
          }
          kubernetes-pods = {
            gnetId     = 6417
            revision   = 1
            datasource = "Prometheus"
          }
        }
      }

      # Security context
      securityContext = {
        runAsNonRoot = true
        runAsUser    = 472
        fsGroup      = 472
      }

      # Labels
      labels = merge(var.labels, {
        company     = var.company
        environment = var.environment
      })
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}
