data "http" "current_ip" {
  url = "https://ipinfo.io/ip"
}

data "namep_azure_name" "aksrg" {
  name     = var.environment
  type     = "azurerm_resource_group"
}

data "namep_azure_name" "aks" {
  name     = var.environment
  type     = "azurerm_kubernetes_cluster"
}

resource "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = data.namep_azure_name.aksrg.result
  name                = data.namep_azure_name.aks.result
  location            = var.location
  tags                = locals.common_tags
  dns_prefix          = var.environment
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = "${var.workspace}pool"
    node_count           = var.default_pool_node_count
    vm_size              = var.default_pool_node_type
    os_disk_size_gb      = 30
    os_disk_type.        = "Ephemeral"
    vnet_subnet_id       = azurerm_subnet.akssubnet.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  api_server_authorized_ip_ranges = [
    "${chomp(data.http.current_ip.body)}/32"
  ]
  
  tags = locals.common_tags

}
