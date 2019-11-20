# Terraform - Create a new Ubuntu machine

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

## Step 2 - Create/Update your terraform tfvars file and update configuration

Create a `secrets.tfvars` file with the following content (update your info)

```text
azure_subscription_id = "<Secret Stuff>"
azure_client_id = "<Secret Stuff>"
azure_client_secret = "<Secret Stuff>"
azure_tenant_id = "<Secret Stuff>"
```

Update the configuration

provider info

```text
provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}
```

Declare variables

```text
variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
```

## Step 3 - Terraform

```text
terraform init
terraform plan -var-file "secrets.tfvars"
terraform apply -var-file "secrets.tfvars" --auto-approve
terraform destroy -var-file "secrets.tfvars" --auto-approve
```


