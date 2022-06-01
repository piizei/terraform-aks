# terraform-aks

This repository is about experimenting with terraforming AKS (Azure Kubernetes Service)

It contains different implementations of AKS in different branches like:
* calico (with windows pool)
* agic (Application Gateway Ingress Controller)


### Notes

Calico needs registering it to windows pools for your subscription: az feature register --namespace "Microsoft.ContainerService" --name "EnableAKSWindowsCalico"


## Workload indentity

Enable preview `az feature register --namespace "Microsoft.ContainerService" --name "EnableOIDCIssuerPreview"`

For workload identity, the service principal needs to be 'application administrator'  in AAD
This is why the terraforming supports also manually created applications.

To use pre-made app-regisration, create a settings file (sp.tfvars for example) and use it like this:
terraform plan -var-file sp.tfvars

The file contents should look like this:
```
use_app_reg = true
app_reg_app_id = "111111-1111-1111-1111-111111111"
app_reg_object_id = "1111111-1111-1111-1111-11111111"
```

If the SP does not have permissions to AAD, you likely need to create the federated indentity credentials manually as well.
To do this add `create_federated_credentials = true` to the tfvars file

if this option is selected, after terraform has created the resources, you can view command to create the credentials with `terraform output`
