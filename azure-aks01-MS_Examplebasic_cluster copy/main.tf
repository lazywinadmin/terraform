terraform {
    backend "azurerm" {}
}

provider "azurerm" {
    version = "~>1.5"
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}
