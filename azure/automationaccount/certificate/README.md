
```text
# Create certificate (example with openssl)
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem

# Combine your key and certificate in a PKCS#12 in a PFX format:
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.pfx
```


```text
terraform init
terraform plan -var-file "secrets.tfvars.json" -out automation.tfplan
terraform apply "automation.tfplan"

terraform plan -var-file "secrets.tfvars.json" -out automation.tfplan -destroy
terraform apply "automation.tfplan"
```

```
# grant permission to sp
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subID>"
```

Output:

```text
{
  "appId": "<Secret Stuff>",         # client_id
  "displayName": "azure-cli-2019-05-26-21-21-54",
  "name": "http://azure-cli-2019-05-26-21-21-54",
  "password": "<Secret Stuff>",      # client_secret
  "tenant": "<Secret Stuff>"         # tenant_id
}
```