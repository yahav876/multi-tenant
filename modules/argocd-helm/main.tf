# ArgoCD Helm Chart Deployment Module
# This module deploys ArgoCD using the official Helm chart

# Create namespace for ArgoCD if needed
resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
    labels = merge(var.labels, {
      name        = var.namespace
      purpose     = "gitops"
      managed-by  = "terraform"
    })
  }
}

# Deploy ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = var.release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.namespace

  # Wait for resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  # ArgoCD Configuration Values
  values = [
    yamlencode({
      global = {
        # Image configuration
        image = {
          repository = "quay.io/argoproj/argocd"
          tag        = var.argocd_version
        }
        
        # Security context
        securityContext = {
          runAsNonRoot = true
          runAsUser    = 999
          fsGroup      = 999
        }
      }

      # ArgoCD Server configuration
      server = {
        # Replicas for high availability
        replicas = var.server_replicas

        # Ingress configuration
        ingress = {
          enabled = var.enable_ingress
          hosts   = var.ingress_hosts
          tls     = var.ingress_tls
          annotations = var.ingress_annotations
        }

        # Service configuration
        service = {
          type = var.service_type
          annotations = var.service_annotations
        }

        # Resource limits and requests
        resources = {
          requests = {
            cpu    = var.server_cpu_request
            memory = var.server_memory_request
          }
          limits = {
            cpu    = var.server_cpu_limit
            memory = var.server_memory_limit
          }
        }

        # Configuration
        config = {
          # Git repositories configuration
          repositories = var.git_repositories
          
          # OIDC configuration (if needed)
          "oidc.config" = var.oidc_config
          
          # URL configuration
          url = var.server_url
        }

        # Extra configuration
        extraArgs = var.server_extra_args
      }

      # ArgoCD Application Controller
      controller = {
        replicas = var.controller_replicas

        resources = {
          requests = {
            cpu    = var.controller_cpu_request
            memory = var.controller_memory_request
          }
          limits = {
            cpu    = var.controller_cpu_limit
            memory = var.controller_memory_limit
          }
        }
      }

      # ArgoCD Repo Server
      repoServer = {
        replicas = var.repo_server_replicas

        resources = {
          requests = {
            cpu    = var.repo_server_cpu_request
            memory = var.repo_server_memory_request
          }
          limits = {
            cpu    = var.repo_server_cpu_limit
            memory = var.repo_server_memory_limit
          }
        }
      }

      # ArgoCD Redis (for caching)
      redis = {
        enabled = true
        
        resources = {
          requests = {
            cpu    = var.redis_cpu_request
            memory = var.redis_memory_request
          }
          limits = {
            cpu    = var.redis_cpu_limit
            memory = var.redis_memory_limit
          }
        }
      }

      # Node selector
      nodeSelector = var.node_selector

      # Tolerations
      tolerations = var.tolerations

      # Affinity
      affinity = var.affinity
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Create ArgoCD Applications for monitoring stack
resource "kubernetes_manifest" "monitoring_application" {
  count = var.create_monitoring_app ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "kube-prometheus-stack"
      namespace = var.namespace
      labels    = merge(var.labels, {
        app        = "kube-prometheus-stack"
        managed-by = "terraform"
      })
    }
    spec = {
      project = "default"
      
      source = {
        repoURL        = var.monitoring_repo_url
        targetRevision = var.monitoring_repo_revision
        path           = var.monitoring_app_path
      }
      
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.monitoring_namespace
      }
      
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}

# Create SSH secret for private Git repository access
resource "kubernetes_secret" "git_ssh_key" {
  count = var.git_ssh_private_key != null ? 1 : 0

  metadata {
    name      = "git-ssh-key"
    namespace = var.namespace
    labels = merge(var.labels, {
      "argocd.argoproj.io/secret-type" = "repository"
    })
  }

  type = "Opaque"

  data = {
    type          = "git"
    url           = var.git_repo_url
    sshPrivateKey = var.git_ssh_private_key
  }

  depends_on = [helm_release.argocd]
}