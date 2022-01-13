variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}

variable "subscription" {
  description = "Id of the Azure subscription"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "n/a"
}

variable "version" {
  description = "Version of the resource"
  type        = string
  default     = "latest"
}

variable "location" {
  description = "Azure location of the resource"
  type        = string
  default     = "westeurope"
}

variable "kubernetes_version" {
  description = "Kubernetes version of AKS"
  type        = string
  default     = "1.22.4"
}

variable "default_pool_node_type" {
  description = "VM type of default nodepool"
  type        = string
  default     = "Standard_B2ms"
}

variable "default_pool_node_count" {
  description = "VM count of default nodepool"
  type        = number
  default     = 1
}
