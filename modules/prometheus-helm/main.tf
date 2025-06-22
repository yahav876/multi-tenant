# Prometheus Module using Helm Provider
# Deploys Prometheus using official Helm charts

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

# Deploy Prometheus using kube-prometheus-stack
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = var.create_namespace ? kubernetes_namespace.monitoring[0].metadata[0].name : var.namespace

  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      # Prometheus configuration
      prometheus = {
        prometheusSpec = {
          retention = var.retention
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes     = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.storage_size
                  }
                }
                # Ensure proper volume expansion support
                volumeMode = "Filesystem"
              }
              metadata = {
                labels = merge(var.labels, {
                  app         = "prometheus"
                  component   = "prometheus"
                  company     = var.company
                  environment = var.environment
                })
              }
            }
          }
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
          nodeSelector = var.node_selector
        }
      }
      
      # Disable Grafana here - we'll deploy it separately
      grafana = {
        enabled = false
      }
      
      # AlertManager configuration
      alertmanager = {
        enabled = var.enable_alertmanager
      }
      
      # Prometheus Operator configuration
      prometheusOperator = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      # Common labels
      commonLabels = merge(var.labels, {
        company     = var.company
        environment = var.environment
      })
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}
