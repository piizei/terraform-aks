# terraform-aks

This repository is about experimenting with terraforming AKS (Azure Kubernetes Service)

It contains different implementations of AKS in different branches like:
* calico (with windows pool)
* agic (Application Gateway Ingress Controller)


### Notes

Calico needs registering it to windows pools for your subscription: az feature register --namespace "Microsoft.ContainerService" --name "EnableAKSWindowsCalico"
