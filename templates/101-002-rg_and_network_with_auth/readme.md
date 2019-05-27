# Terraform - Create Resource Group and Network (auth via env variables)

## Step 1 - Authenticate

See the different options: https://www.terraform.io/docs/providers/azurerm/index.html

Here we create a Service Principal and grant contributor on the Subscription

Run the following in Azure Cloud Shell

```text
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"
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

## Step 2 - Update your terraform configuration

Update the provider information

```powershell
provider "azurerm" {
    ARM_CLIENT_ID="<Secret Stuff>"
    ARM_CLIENT_SECRET="<Secret Stuff>"
    ARM_SUBSCRIPTION_ID="<Secret Stuff>"
    ARM_TENANT_ID="<Secret Stuff>"
}
```

## Step 3 - Terraform

```text
terraform init
terraform plan
terraform apply
```