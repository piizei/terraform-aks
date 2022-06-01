locals {
    awi_namespace = "default"
}


# For this the service principal needs to be 'application administrator'
resource "azuread_application" "default" {
  count = var.use_app_reg ? 0 : 1
  display_name = "aks-${var.environment}-service-principal"
}

resource "azuread_service_principal" "default" {
  count = var.use_app_reg ? 0 : 1
  application_id               = var.use_app_reg ?  var.app_reg_app_id : azuread_application.default[0].application_id 
  app_role_assignment_required = false
}

# For these the service principal needs to be 'application administrator'
resource "azuread_application_federated_identity_credential" "default" {
  count = var.create_federated_credentials ? 0 : 1
  application_object_id = var.use_app_reg ?  var.app_reg_object_id: azuread_application.default[0].object_id
  display_name          = "kubernetes-federated-credential"
  description           = "Kubernetes service account federated credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject               = "system:serviceaccount:workload-identity-sa:${var.environment}"
}


resource "helm_release" "awi" {
  name       = "azure-workload-identity"
  chart      = "workload-identity-webhook"
  repository = "https://azure.github.io/azure-workload-identity/charts"

  namespace        = local.awi_namespace
  create_namespace = true

  set {
    name  = "azureTenantID"
    value = data.azurerm_subscription.current.tenant_id
  }
}

resource "kubernetes_service_account" "aks" {
  metadata {
    name      = "service-account-${var.environment}"
    namespace = local.awi_namespace
    annotations = {
      "azure.workload.identity/client-id" = var.use_app_reg ? var.app_reg_app_id : azuread_application.default[0].application_id
    }
    labels = {
      "azure.workload.identity/use" : "true"
    }
  }
}

#Output the details to create the federated identity credentials manually
output "federated_identity_command" {
  value = "az rest --method POST --uri 'https://graph.microsoft.com/beta/applications/${var.use_app_reg ? var.app_reg_object_id : azuread_application.default[0].object_id}/federatedIdentityCredentials' --body '{\"name\":\"Kubernetes-federated-credential\",\"issuer\":\"${azurerm_kubernetes_cluster.aks.oidc_issuer_url}\",\"subject\":\"system:serviceaccount:workload-identity-sa:${var.environment}\",\"description\":\"Kubernetes service account federated credential\",\"audiences\":[\"api://AzureADTokenExchange\"]}'"
}
