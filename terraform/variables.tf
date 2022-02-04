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
  #To figure out whats the cheapest VM type that supports ephemeral disks in your region,  use https://ephemeraldisk.danielstechblog.de/api/ephemeraldisk?location=westeurope
}

variable "default_pool_node_count" {
  description = "VM count of default nodepool"
  type        = number
  default     = 1 #Set to number that makes sense for the Availability Zones as well (min 3 for 3 zones...)
}

variable "availability_zones" {
  description = "AZs where nodepool vms are deployed"
  type        = list(string)
  default     = ["1"]
}

variable "win_admin" {
  description = "Admin username of the windows nodepool machines"
  type        = string
  default     = "Administrator"
}

