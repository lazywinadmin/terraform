# First setup your authentication
#  https://www.terraform.io/docs/providers/azurerm/index.html
#  example: create sp with secret
#   az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

# PROVIDER
# https://www.terraform.io/docs/providers/azurerm/index.html
# Configure the Azure Provider

provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

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

variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}