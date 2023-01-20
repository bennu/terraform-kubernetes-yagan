terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = ">= 1.3.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
  required_version = ">= 1.3.7"
}