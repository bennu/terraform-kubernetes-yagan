terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = ">= 1.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}