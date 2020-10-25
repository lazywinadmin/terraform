resource "azurerm_resource_group" "example" {
  name     = "testappservoutb"
  location = "West US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "fxexample-appserviceplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_virtual_network" "example" {
  name          = "test-network"
  address_space = ["10.1.2.0/24"]
  location      = "West US"
  resource_group_name = azurerm_resource_group.example.name
}
resource "azurerm_subnet" "example" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.2.0/25"]


  delegation {
    name = "vnet-integration"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service" "example" {
  name                = "fxexample-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

https_only = true

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "None"
    min_tls_version = "1.2"
    #ip_restriction {
    #    virtual_network_subnet_id = azurerm_subnet.example.id
    #}
  }

}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.example.id
  subnet_id      = azurerm_subnet.example.id
}