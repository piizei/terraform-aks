variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "n/a"
}

variable "release_version" {
  description = "Version of the infrastructure automation"
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
  default     = "Standard_D2s_v3" 
  #To figure out whats the cheapest VM type that supports ephemeral disks in your region, use https://ephemeraldisk.danielstechblog.de/api/ephemeraldisk?location=westeurope
}

variable "default_pool_node_count" {
  description = "VM count of default nodepool"
  type        = number
  default     = 1
}
