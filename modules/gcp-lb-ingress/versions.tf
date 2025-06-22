terraform {
  required_version = ">= 1.3"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
}