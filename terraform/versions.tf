terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.8.0"
    }
    namep = {
      source  = "jason-johnson/namep"
      version = ">=1.0.5"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}