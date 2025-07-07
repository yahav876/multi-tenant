resource "kubernetes_manifest" "app_of_apps" {
  count = var.create_app_of_apps ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = var.argocd_namespace
      labels    = merge(var.labels, {
        app        = "app-of-apps"
        managed-by = "terraform"
      })
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.app_of_apps_repo_url
        targetRevision = var.app_of_apps_repo_revision
        path           = var.app_of_apps_path
        kustomize      = {}
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
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
          "PruneLast=true",
          "ServerSideApply=true"
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
}

resource "kubernetes_manifest" "app_of_apps_services" {
  count = var.create_app_of_apps ? 1 : 0

  lifecycle {
    ignore_changes = [manifest.metadata[0].finalizers]
  }

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "services-app-of-apps"
      namespace = var.argocd_namespace
      labels = {
        app        = "services-app-of-apps"
        managed-by = "terraform"
      }
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.app_of_apps_repo_url
        targetRevision = var.app_of_apps_repo_revision
        path           = var.app_of_apps_path_services
        kustomize      = {}
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
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
          "PruneLast=true",
          "ServerSideApply=true"
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
}
