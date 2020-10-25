locals {
    policyname = "test-policy_law-tf"
    mgmtgroupname = ""
}

provider "azurerm" {
  version = "~> 2.18.0"
  features {}
}

provider "local" {
}

resource "azurerm_policy_definition" "example" {
  name         = "pol-${local.policyname}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = local.policyname
  description  = "null"
  management_group_name = local.mgmtgroupname

  policy_rule = file("./policy.json")
  parameters = file("./policy.parameters.json")
}

resource "azurerm_policy_assignment" "example" {
  name                 = "pol-${local.policyname}"
  scope                = azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.example.id
  description          = "pol-${local.policyname}"
  display_name         = "pol-${local.policyname}"
  location              = "west us"
  identity {
      type = "SystemAssigned"
  }

  metadata = <<METADATA
    {
    "category": "General"
    }
METADATA

  parameters = <<PARAMETERS
{
  "logAnalytics": {
    "value": [ "/subscriptions/b70ae6c2-7420-4191-8671-bc8caaf7cd48/resourcegroups/law/providers/microsoft.operationalinsights/workspaces/fxtest-law" ]
  }
}
PARAMETERS
}

resource "azurerm_role_assignment" "owner" {
  scope                = azurerm_policy_assignment.example.scope
  role_definition_name = "Owner"
  principal_id         = azurerm_policy_assignment.example.identity[0].principal_id
}

resource "azurerm_role_assignment" "uaa" {
  scope                = azurerm_policy_assignment.example.scope
  role_definition_name = "User Access Administrator"
  principal_id         = azurerm_policy_assignment.example.identity[0].principal_id
}

resource "azurerm_policy_remediation" "example" {
  name                 = "pol-${local.policyname}-rem"
  scope                = azurerm_policy_assignment.example.scope
  policy_assignment_id = azurerm_policy_assignment.example.id
  location_filters     = []
}

# Rg to test if this work
resource "azurerm_resource_group" "example" {
  name     = "pol-${local.policyname}-rg"
  location = "west us"
}