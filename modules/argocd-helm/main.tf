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


# # File: modules/argocd-helm/main.tf

# # ArgoCD Helm Release
# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   version    = var.chart_version
#   namespace  = var.namespace

#   values = var.values_file_path != "" ? [
#     file(var.values_file_path)
#   ] : [
#     templatefile("${path.module}/values.yaml.tpl", {
#       namespace = var.namespace
#       labels    = var.labels
#     })
#   ]

#   # Force update to ensure proper ArgoCD installation
#   force_update    = true
#   cleanup_on_fail = true
#   wait            = true
#   timeout         = 600

# }

# # Wait for ArgoCD to be ready
# resource "time_sleep" "wait_for_argocd" {
#   depends_on = [helm_release.argocd]
#   create_duration = "60s"
# }

# # Get ArgoCD server service for external access
# data "kubernetes_service" "argocd_server" {
#   metadata {
#     name      = "argocd-server"
#     namespace = var.namespace
#   }
#   depends_on = [helm_release.argocd, time_sleep.wait_for_argocd]
# }

# # Create SSH secret for repository access
# resource "kubernetes_secret" "repo_ssh_secret" {
#   count = var.git_ssh_private_key != "" ? 1 : 0

#   metadata {
#     name      = "repo-ssh-secret"
#     namespace = var.namespace
#     labels = merge(var.labels, {
#       "argocd.argoproj.io/secret-type" = "repository"
#     })
#   }

#   type = "Opaque"

#   data = {
#     type          = "git"
#     url           = var.git_repo_url
#     sshPrivateKey = var.git_ssh_private_key
#   }

#   depends_on = [helm_release.argocd]
# }

# # Create App of Apps ArgoCD Application
# resource "kubernetes_manifest" "app_of_apps" {
#   count = var.create_app_of_apps && var.app_of_apps_repo_url != "" ? 1 : 0

#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "app-of-apps"
#       namespace = var.namespace
#       labels    = merge(var.labels, {
#         app        = "app-of-apps"
#         managed-by = "terraform"
#       })
#       finalizers = [
#         "resources-finalizer.argocd.argoproj.io"
#       ]
#     }
#     spec = {
#       project = "default"
      
#       source = {
#         repoURL        = var.app_of_apps_repo_url
#         targetRevision = var.app_of_apps_repo_revision
#         path           = var.app_of_apps_path
#       }
      
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = var.namespace
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

#   depends_on = [helm_release.argocd, time_sleep.wait_for_argocd]
# }
