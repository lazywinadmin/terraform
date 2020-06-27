provider "azurerm" {
  version = "2.0.0"
  features {}
  subscription_id = var.subscription_id
  client_id = var.appId
  client_secret = var.password
  tenant_id = var.tenant
}

provider "local" {
  version = "~> 1.4"
}