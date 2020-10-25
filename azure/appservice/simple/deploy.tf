# Configure the Azure provider
provider "azurerm" { }

resource "azurerm_resource_group" "slotDemo" {
    name = "slotDemoResourceGroup"
    location = "westus2"
}

resource "azurerm_app_service_plan" "slotDemo" {
    name                = "slotAppServicePlan"
    location            = azurerm_resource_group.slotDemo.location
    resource_group_name = azurerm_resource_group.slotDemo.name
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "slotDemo" {
    name                = "slotAppService"
    location            = azurerm_resource_group.slotDemo.location
    resource_group_name = azurerm_resource_group.slotDemo.name
    app_service_plan_id = azurerm_app_service_plan.slotDemo.id
}

resource "azurerm_app_service_slot" "slotDemo" {
    name                = "slotAppServiceSlotOne"
    location            = azurerm_resource_group.slotDemo.location
    resource_group_name = azurerm_resource_group.slotDemo.name
    app_service_plan_id = azurerm_app_service_plan.slotDemo.id
    app_service_name    = azurerm_app_service.slotDemo.name
}