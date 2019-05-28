# using Terraform Modules
# https://learn.hashicorp.com/terraform/azure/modules_az
# edited to support my tfvars

# declare variables and defaults
variable "location" {
    default = "westus2"
}
variable "environment" {
    default = "dev"
}
variable "vm_size" {
    default = {
        "dev"   = "Standard_B2s"
        "prod"  = "Standard_D2s_v3"
    }
}

provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "myResourceGroup"
    location = "${var.location}"
}

# Use the network module to create a vnet and subnet
module "network" {
    source              = "Azure/network/azurerm"
    location            = "${var.location}"
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = "10.0.0.0/16"
}
