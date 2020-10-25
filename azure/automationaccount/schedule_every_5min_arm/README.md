
```text
terraform init
terraform plan -var-file "secrets.tfvars" -out automation.tfplan
terraform apply "automation.tfplan"
terraform plan -var-file "secrets.tfvars" -out automation.tfplan -destroy
terraform apply "automation.tfplan"
```

```
# grant permission to sp

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subID>"
az role assignment create --assignee <appid> --role 'Resource Policy Contributor'

```