locals {
  common_tags = {
    environment = var.env
    owner       = var.owner
    version     = var.version
  }
}