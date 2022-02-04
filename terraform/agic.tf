data "namep_azure_name" "appgw" {
  name     = var.environment
  type     = "azurerm_application_gateway"
}

data "namep_azure_name" "pip" {
  name     = var.environment
  type     = "azurerm_public_ip"
}

# Grant AKS access to AppGw
resource "azurerm_role_assignment" "agic" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = azurerm_application_gateway.appgw.id
  role_definition_name = "Contributor"
}

resource "azurerm_public_ip" "pip" {
  name                = data.namep_azure_name.pip.result
  resource_group_name = azurerm_resource_group.aksrg.name
  location            = azurerm_resource_group.aksrg.location
  allocation_method   = "Static"
  tags = local.common_tags
}


resource "azurerm_application_gateway" "appgw" {
    name                = data.namep_azure_name.appgw.result
    resource_group_name = azurerm_resource_group.aksrg.name
    location            = azurerm_resource_group.aksrg.location

    sku {
      name     = "Standard_v2"
      tier     = "Standard_v2"
      capacity = 1
    }

    gateway_ip_configuration {
      name      = "appGatewayIpConfig"
      subnet_id =  azurerm_subnet.appgw.id
    }

    frontend_port {
      name = "${azurerm_virtual_network.vnet.name}-feport-http"
      port = 80
    }

    frontend_port {
      name = "${azurerm_virtual_network.vnet.name}-feport-https"
      port = 443
    }

    frontend_ip_configuration {
      name                 = "${azurerm_virtual_network.vnet.name}-feip"
      public_ip_address_id = azurerm_public_ip.pip.id
    }

    backend_address_pool {
      name = "${azurerm_virtual_network.vnet.name}-beap"
    }

    backend_http_settings {
      name                  = "${azurerm_virtual_network.vnet.name}-be-htst"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 1
    }

    http_listener {
      name                           = "${azurerm_virtual_network.vnet.name}-httplstn"
      frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
      frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport-http"
      protocol                       = "Http"
    }

    request_routing_rule {
    name                       = "${azurerm_virtual_network.vnet.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${azurerm_virtual_network.vnet.name}-httplstn"
    backend_address_pool_name  = "${azurerm_virtual_network.vnet.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-be-htst"
    }

    tags = local.common_tags

    # Ingress controller manages most of these
    lifecycle {
        ignore_changes = [
            backend_address_pool,
            backend_http_settings,
            frontend_port,
            http_listener,
            probe,
            request_routing_rule,
            url_path_map,
            ssl_certificate,
            redirect_configuration,
            autoscale_configuration,
            tags
        ]
    }

  }

  resource "kubernetes_namespace" "agic" {
      metadata {
          name = "ingress-agic"
      }
      depends_on = [azurerm_kubernetes_cluster.aks]
  }

resource "helm_release" "ingress_azure" {
  name         = "application-gateway-kubernetes"
  repository   = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart        = "ingress-azure"
  version      = "1.5.0"
  force_update = true
  namespace    =  "ingress-agic"

  set {
      name  = "subscriptionId"
      value =  data.azurerm_subscription.current.subscription_id
  }
  set {
      name  = "resourceGroup"
      value =  azurerm_resource_group.aksrg.name
  }
  set {
      name  = "applicationgateway_name"
      value =  azurerm_application_gateway.appgw.name
  }
  set {
      name  = "identityResourceID"
      value =  azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  }
  set {
      name  = "identityClientId"
      value =  azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
  }

  depends_on = [kubernetes_namespace.agic]
}
