
```text
terraform init
terraform plan -var-file "secrets.tfvars" -out policy.tfplan
terraform apply "policy.tfplan"
terraform plan -var-file "secrets.tfvars" -out policy.tfplan -destroy
terraform apply "policy.tfplan"
```

```
# grant permission to sp

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subID>"
az role assignment create --assignee <appid> --role 'Resource Policy Contributor'

```