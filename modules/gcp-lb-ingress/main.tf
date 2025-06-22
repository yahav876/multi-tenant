# GCP Load Balancer Controller + Ingress Module
# This module creates the necessary resources for exposing services via GCP Load Balancer using Ingress
# Designed for GKE clusters with proper security configurations

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Create static IP address for the load balancer
resource "google_compute_global_address" "lb_ip" {
  count        = var.create_static_ip ? 1 : 0
  name         = "${var.name_prefix}-lb-ip"
  project      = var.project_id
  description  = "Static IP for ${var.name_prefix} Load Balancer"
  
  labels = merge(var.labels, {
    component = "load-balancer"
    purpose   = "ingress"
  })
}

# Create SSL certificate if HTTPS is enabled
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count   = var.enable_ssl && length(var.ssl_domains) > 0 ? 1 : 0
  name    = "${var.name_prefix}-ssl-cert"
  project = var.project_id

  managed {
    domains = var.ssl_domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create BackendConfig for health checks and other backend configurations
resource "kubernetes_manifest" "backend_config" {
  count = var.create_backend_config ? 1 : 0
  
  manifest = {
    apiVersion = "cloud.google.com/v1"
    kind       = "BackendConfig"
    metadata = {
      name      = "${var.name_prefix}-backend-config"
      namespace = var.namespace
      labels = merge(var.labels, {
        component = "backend-config"
      })
    }
    spec = {
      # Health check configuration
      healthCheck = {
        checkIntervalSec   = var.health_check_interval
        timeoutSec        = var.health_check_timeout
        healthyThreshold  = var.health_check_healthy_threshold
        unhealthyThreshold = var.health_check_unhealthy_threshold
        type              = var.health_check_type
        requestPath       = var.health_check_path
        port              = var.health_check_port
      }
      
      # Session affinity configuration
      sessionAffinity = {
        affinityType         = var.session_affinity_type
        affinityCookieTtlSec = var.session_affinity_cookie_ttl
      }
      
      # Timeout configuration
      timeoutSec = var.backend_timeout
      
      # Connection draining
      connectionDraining = {
        drainingTimeoutSec = var.connection_draining_timeout
      }
      
      # Security policy
      securityPolicy = var.security_policy_name != "" ? {
        name = var.security_policy_name
      } : null
      
      # CDN configuration
      cdn = var.enable_cdn ? {
        enabled = true
        cachePolicy = {
          includeHost        = true
          includeProtocol    = true
          includeQueryString = var.cdn_include_query_string
        }
      } : null
    }
  }
}

# Create the Ingress resource
resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "${var.name_prefix}-ingress"
    namespace = var.namespace
    
    annotations = merge(
      {
        # Use GKE Ingress Controller
        "kubernetes.io/ingress.class" = "gce"
        
        # Static IP assignment
        "kubernetes.io/ingress.global-static-ip-name" = var.create_static_ip ? google_compute_global_address.lb_ip[0].name : var.existing_static_ip_name
        
        # SSL configuration
        "ingress.gke.io/managed-certificates" = var.enable_ssl && length(var.ssl_domains) > 0 ? google_compute_managed_ssl_certificate.ssl_cert[0].name : ""
        
        # HTTPS redirect
        "kubernetes.io/ingress.allow-http" = var.allow_http ? "true" : "false"
        
        # Load balancer type (External or Internal)
        "kubernetes.io/ingress.class" = var.load_balancer_type == "Internal" ? "gce-internal" : "gce"
        
        # FrontendConfig for additional frontend configurations
        "ingress.gke.io/frontend-config" = var.frontend_config_name != "" ? var.frontend_config_name : ""
      },
      var.custom_annotations
    )
    
    labels = merge(var.labels, {
      component = "ingress"
      app       = var.name_prefix
    })
  }

  spec {
    # Default backend - optional
    dynamic "default_backend" {
      for_each = var.default_backend_service != "" ? [1] : []
      content {
        service {
          name = var.default_backend_service
          port {
            number = var.default_backend_port
          }
        }
      }
    }

    # Rules for different hosts/paths
    dynamic "rule" {
      for_each = var.ingress_rules
      content {
        host = rule.value.host
        http {
          dynamic "path" {
            for_each = rule.value.paths
            content {
              path      = path.value.path
              path_type = path.value.path_type
              backend {
                service {
                  name = path.value.service_name
                  port {
                    number = path.value.service_port
                  }
                }
              }
            }
          }
        }
      }
    }

    # TLS configuration
    dynamic "tls" {
      for_each = var.enable_ssl && length(var.ssl_domains) > 0 ? [1] : []
      content {
        hosts       = var.ssl_domains
        secret_name = var.tls_secret_name
      }
    }
  }

  wait_for_load_balancer = true

  depends_on = [
    google_compute_global_address.lb_ip,
    google_compute_managed_ssl_certificate.ssl_cert,
    kubernetes_manifest.backend_config
  ]
}

# Create FrontendConfig for additional frontend configurations (optional)
resource "kubernetes_manifest" "frontend_config" {
  count = var.create_frontend_config ? 1 : 0
  
  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"
    metadata = {
      name      = "${var.name_prefix}-frontend-config"
      namespace = var.namespace
      labels = merge(var.labels, {
        component = "frontend-config"
      })
    }
    spec = {
      # Redirect HTTP to HTTPS
      redirectToHttps = {
        enabled = var.redirect_http_to_https
      }
      
      # SSL policy
      sslPolicy = var.ssl_policy_name != "" ? {
        name = var.ssl_policy_name
      } : null
    }
  }
}

# Create firewall rule for health checks
resource "google_compute_firewall" "health_check" {
  count   = var.create_health_check_firewall ? 1 : 0
  name    = "${var.name_prefix}-health-check-fw"
  project = var.project_id
  network = var.network_name

  description = "Allow health check for ${var.name_prefix} load balancer"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.health_check_port)]
  }

  # Google Cloud health check source ranges
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = var.target_tags

  direction = "INGRESS"
}

# Create firewall rule for load balancer access from authorized networks
resource "google_compute_firewall" "lb_access" {
  count   = var.create_access_firewall && length(var.authorized_source_ranges) > 0 ? 1 : 0
  name    = "${var.name_prefix}-lb-access-fw"
  project = var.project_id
  network = var.network_name

  description = "Allow access to ${var.name_prefix} load balancer from authorized networks"

  allow {
    protocol = "tcp"
    ports    = var.allow_http ? ["80", "443"] : ["443"]
  }

  source_ranges = var.authorized_source_ranges
  target_tags   = var.target_tags

  direction = "INGRESS"
}
