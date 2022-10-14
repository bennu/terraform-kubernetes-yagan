terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = ">= 1.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
  required_version = ">= 0.13"
}