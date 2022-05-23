terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
    namep = {
      source  = "jason-johnson/namep"
      version = ">=1.0.4"
    }
     github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.12.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=3.2.1"
    }
  }
}