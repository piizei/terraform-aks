provider "namep" {
  default_location = var.location
  extra_tokens = {
    env = var.environment
  }
  # Using the default formatting #{SLUG}#{SHORT_LOC}#{NAME} for most resources, but its confusing for RGs
  resource_formats = {
    azurerm_resource_group = "#{SLUG}-#{SHORT_LOC}-#{ENV}-#{NAME}"
  }
}

provider "azurerm" {
  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
    }
  }
}
provider "azuread" {
  tenant_id = data.azurerm_subscription.current.tenant_id
}


provider "kubernetes" {
  host = azurerm_kubernetes_cluster.aks.kube_config[0].host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.aks.kube_config[0].host

    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}


data "azurerm_subscription" "current" {}
