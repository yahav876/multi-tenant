resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.argocd_namespace

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      git_repo_url = var.git_repo_url
    })
  ]

  force_update    = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600
}

resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "60s"
}

resource "kubernetes_secret" "repo_ssh_secret" {
  metadata {
    name      = "repo-ssh-secret"
    namespace = var.argocd_namespace
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

# (Optional) App of Apps Application creation
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
  depends_on = [helm_release.argocd, time_sleep.wait_for_argocd]
}

resource "kubernetes_manifest" "app_of_apps_services" {
  count = var.create_app_of_apps ? 1 : 0
    lifecycle {
    ignore_changes = [
      manifest.metadata[0].finalizers
    ]
  }

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "services-app-of-apps"
      namespace = var.argocd_namespace
      labels    = {
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
        },
        
      }
    }
  }
}




# resource "kubernetes_manifest" "app_of_apps_path_applications" {
#   count = var.create_app_of_apps ? 1 : 0
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "applications-app-of-apps"
#       namespace = var.argocd_namespace
#       labels    = {
#         app        = "applications-app-of-apps"
#         managed-by = "terraform"
#       }
#       finalizers = ["resources-finalizer.argocd.argoproj.io"]
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL        = var.app_of_apps_repo_url
#         targetRevision = var.app_of_apps_repo_revision
#         path           = var.app_of_apps_path_services
#         kustomize      = {}
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = var.argocd_namespace
#       }
#       syncPolicy = {
#         automated = {
#           prune      = true
#           selfHeal   = true
#           allowEmpty = false
#         }
#         syncOptions = [
#           "CreateNamespace=true",
#           "PrunePropagationPolicy=foreground",
#           "PruneLast=true",
#           "ServerSideApply=true"
#         ]
#         retry = {
#           limit = 5
#           backoff = {
#             duration    = "5s"
#             factor      = 2
#             maxDuration = "3m"
#           }
#         }
#       }
#     }
#   }
# }
