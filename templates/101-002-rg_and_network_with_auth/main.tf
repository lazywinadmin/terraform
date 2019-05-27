# First setup your authentication
#  https://www.terraform.io/docs/providers/azurerm/index.html
#  example: create sp with secret
#   az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

# PROVIDER
# https://www.terraform.io/docs/providers/azurerm/index.html
# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  #version = "=1.28.0"
    ARM_CLIENT_ID="<Secret Stuff>"
    ARM_CLIENT_SECRET="<Secret Stuff>"
    ARM_SUBSCRIPTION_ID="<Secret Stuff>"
    ARM_TENANT_ID="<Secret Stuff>"
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

