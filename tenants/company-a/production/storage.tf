# Storage Configuration for GKE
# Ensure proper storage classes and CSI drivers are available

# Create custom storage classes for specific use cases
resource "kubernetes_storage_class" "fast_ssd" {
  metadata {
    name = "fast-ssd"
    labels = local.common_labels
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy        = "Delete"

  parameters = {
    type                = "pd-ssd"
    zones               = join(",", var.gcp_region == "us-west1" ? ["us-west1-a", "us-west1-b", "us-west1-c"] : [])
    replication-type    = "none"
    provisioner-secret-name      = ""
    provisioner-secret-namespace = ""
    controller-expand-secret-name      = ""
    controller-expand-secret-namespace = ""
    node-stage-secret-name      = ""
    node-stage-secret-namespace = ""
    node-publish-secret-name      = ""
    node-publish-secret-namespace = ""
  }

  depends_on = [module.gke]
}

resource "kubernetes_storage_class" "balanced_ssd" {
  metadata {
    name = "balanced-ssd"
    labels = local.common_labels
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy        = "Delete"

  parameters = {
    type                = "pd-balanced"
    zones               = join(",", var.gcp_region == "us-west1" ? ["us-west1-a", "us-west1-b", "us-west1-c"] : [])
    replication-type    = "none"
  }

  depends_on = [module.gke]
}

# Create a priority class for monitoring workloads
resource "kubernetes_priority_class" "monitoring_priority" {
  metadata {
    name = "monitoring-priority"
    labels = local.common_labels
  }

  value          = 1000
  global_default = false
  description    = "Priority class for monitoring workloads"

  depends_on = [module.gke]
}
