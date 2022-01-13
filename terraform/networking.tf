
data "namep_azure_name" "vnet" {
  name     = "shared"
  type     = "azurerm_virtual_network"
}

data "namep_azure_name" "akssubnet" {
  name     = "aks"
  type     = "azurerm_subnet"
}

data "namep_azure_name" "vnetrg" {
  name     = "vnet"
  type     = "azurerm_resource_group"
}

resource "azurerm_resource_group" "vnet" {
  name = data.namep_azure_name.vnetrg.result
  location = var.location
  tags = local.common_tags
}


resource "azurerm_virtual_network" "vnet" {
  name                = data.namep_azure_name.vnet.result
  resource_group_name = azurerm_resource_group.vnet.name
  location            = var.location
  address_space       = ["10.0.0.0/8"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                                           = data.namep_azure_name.akssubnet.result
  resource_group_name                            = azurerm_resource_group.vnet.name
  address_prefixes                               = ["10.1.0.0/16"]
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}