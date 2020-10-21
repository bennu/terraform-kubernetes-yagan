terraform {
  required_version = ">= 0.13"
  required_providers {
    rke = {
      version = ">= 1.1.3"
      source  = "rancher/rke"
    }
    helm = {
      source = "hashicorp/helm"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
