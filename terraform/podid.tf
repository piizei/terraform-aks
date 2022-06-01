resource "azurerm_user_assigned_identity" "podid" {
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  location            = azurerm_kubernetes_cluster.aks.location
  name                = "aks-${var.environment}-podid"
  tags                = local.common_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "podid_contributor" {
  scope                = "${data.azurerm_subscription.current.id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.podid.principal_id
}

resource "azurerm_role_assignment" "vmcontributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "additional_managed_identity_operator" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

module "aad_pod_identity" {
  source     = "git::https://github.com/danielscholl-terraform/module-aad-pod-identity?ref=v1.0.0"
  depends_on = [azurerm_kubernetes_cluster.aks]

  providers = { helm = helm.aks }

  aks_node_resource_group = azurerm_kubernetes_cluster.aks.node_resource_group
  aks_identity            = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  identities = {
    // Add an AzureIdentity and Binding for Pod Identity to the cluster
    pod-identity = {
      namespace   = "default"
      name        = azurerm_user_assigned_identity.podid.name
      client_id   = azurerm_user_assigned_identity.podid.client_id
      resource_id = azurerm_user_assigned_identity.podid.id
    }
  }
}



