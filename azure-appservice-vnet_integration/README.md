
# App Service with HTTPS/TLS 1.2/VNET Integration (for outbound traffic)

## Summary

This example:
* create resource group
* create a app service plan
* create a webapp with HTTPS and TLS 1.2
* create a vnet integration on the webapp

We are authenticating using a SPN, see requirements below.

## Requirements
### Authentication using a Service Principal Name account (SPN)

Create and Grant appropriate permissions to the SPN, here for example 'Contributor'

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subID>"
```

Example of Output

```text
{
  "appId": "<Secret Stuff>",         # client_id
  "displayName": "azure-cli-2019-05-26-21-21-54",
  "name": "http://azure-cli-2019-05-26-21-21-54",
  "password": "<Secret Stuff>",      # client_secret
  "tenant": "<Secret Stuff>"         # tenant_id
}
```

### Create the secrets.tfvars.json file

```
{
  "appId": "<spn app id>",
  "password": "<spn password>",
  "tenant": "<tenant id>",
  "subscription_id": "<sub id>"
}
```

## Executing Terraform

```text
# Creating the resources
terraform init
terraform plan -var-file "secrets.tfvars.json" -out automation.tfplan
terraform apply "automation.tfplan"

# Destroying the resources
terraform plan -var-file "secrets.tfvars.json" -out automation.tfplan -destroy
terraform apply "automation.tfplan"
```