provider "namep" {
  default_location = var.location
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}
