
data "namep_azure_name" "vnet" {
  name     = var.environment
  type     = "azurerm_virtual_network"
}

data "namep_azure_name" "akssubnet" {
  name     = var.environment
  type     = "azurerm_subnet"
}

resource "azurerm_virtual_network" "vnet" {
  name                = data.namep_azure_name.vnet.result
  resource_group_name = azurerm_resource_group.aks.name
  location            = var.location
  address_space       = ["10.0.0.0/8"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                                           = data.namep_azure_name.akssubnet.result
  resource_group_name                            = azurerm_resource_group.aks.name
  address_prefixes                               = ["10.1.0.0/16"]
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}