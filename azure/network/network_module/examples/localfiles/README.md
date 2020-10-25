
```text
terraform init
terraform plan -var-file "secrets.tfvars"
terraform apply -var-file "secrets.tfvars" --auto-approve
terraform destroy -var-file "secrets.tfvars" --auto-approve

terraform init
terraform plan -var-file "secrets.tfvars" -var resource_group_name=main-vnet -out vnet.tfplan
terraform apply "vnet.tfplan"
terraform plan -destroy -var-file "secrets.tfvars" -out vnetdestroy.tfplan
terraform apply vnetdestroy.tfplan
```



terraform init -plugin-dir ../plugins -reconfigure
terraform plan -var-file "secrets.tfvars" -out vnet.tfplan
terraform apply "vnet.tfplan"
