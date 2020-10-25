locals {
    rgname = "test-appservice"
    policyname = "test-appservice-tls12"
    mgmtgroupname = ""
    policyversion = "0.0.1"
    policycategory = "test"
    location = "west us"
}

provider "azurerm" {
  version = "~> 2.18.0"
  features {}
}

provider "local" {
}

data "azurerm_resource_group" "example" {
  name= local.rgname
}

resource "azurerm_app_service_plan" "example" {
  name                = "${local.policyname}-appsvcplan"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "${local.policyname}-appsvc"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id


  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    min_tls_version = "1.2"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}
