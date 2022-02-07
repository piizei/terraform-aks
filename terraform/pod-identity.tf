data "azurerm_user_assigned_identity" "agentpool" {
  name                =  "${azurerm_kubernetes_cluster.aks.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
data "azurerm_resource_group" "node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group

}

resource "azurerm_role_assignment" "kubelet_managed_id_operator" {
  scope                = azurerm_resource_group.aksrg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "agentpool_msi" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true

}
resource "azurerm_role_assignment" "agentpool_vm" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Virtual Machine Contributor"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true
}

locals {
  aad_pod_identity_settings = {
    forceNameSpaced = false
    mic = {
      image = "mic"
      tag   = "v1.8.6"
      resources = {
        limits = {
          cpu    = "200m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "512Mi"
        }
      }
    }
    nmi = {
      image = "nmi"
      tag   = "v1.8.6"
      resources = {
        limits = {
          cpu    = "200m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    }
    rbac = {
      enabled = true
    }
    installCRDs = true
  }
}
resource "helm_release" "aad_pod_identity_release" {
  name         = "aad-pod-identity"
  chart        = "aad-pod-identity"
  version      = "4.1.7"
  repository   = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  namespace    = "kube-system"
  max_history  = 4
  atomic       = true
  reuse_values = false
  timeout      = 1800
  values       = [yamlencode(local.aad_pod_identity_settings)]
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]

}