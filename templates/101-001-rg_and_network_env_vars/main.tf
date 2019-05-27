# First setup your authentication
#  https://www.terraform.io/docs/providers/azurerm/index.html
#  example: create sp with secret
#   az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

#{
#  "appId": "<Secret Stuff>",         # client_id
#  "displayName": "azure-cli-2019-05-26-21-21-54",
#  "name": "http://azure-cli-2019-05-26-21-21-54",
#  "password": "<Secret Stuff>",      # client_secret
#  "tenant": "<Secret Stuff>"         # tenant_id
#}

# Set environement variable, used by terraform
#$env:ARM_CLIENT_ID="<Secret Stuff>"
#$env:ARM_CLIENT_SECRET="<Secret Stuff>"
#$env:ARM_SUBSCRIPTION_ID="<Secret Stuff>"
#$env:ARM_TENANT_ID="<Secret Stuff>"

# VARIABLES
#variable "azure_access_key" {}
#variable "azure_secret_key" {}
#variable "private_key_path" {}
#variable "key_name" {
#    default = "pluralsight"
#}

# PROVIDER
# https://www.terraform.io/docs/providers/azurerm/index.html
# Configure the Azure Provider
provider "azurerm" {}

# RESOURCES
# Create a resource group
resource "azurerm_resource_group" "demofx" {
  name     = "demofx"
  location = "westus2"
  tags = {
    env   = "demo"
    build = "demo1"
  }
}

# create a virtual network in the RG
resource "azurerm_virtual_network" "demofx_network" {
  name                = "demo01_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demofx.location
  resource_group_name = azurerm_resource_group.demofx.name

  subnet {
    name           = "demo01_public_subnet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "demo01_private_subnet"
    address_prefix = "10.0.2.0/24"
  }
  tags = {
    env   = "demo"
    build = "demo1"
    gnia = "demo1"
  }
}

