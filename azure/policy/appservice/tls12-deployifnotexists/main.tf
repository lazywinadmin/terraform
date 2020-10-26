locals {
    policyname = "test-appservice-tls12"
}

data "azurerm_resource_group" "example" {
  name = "test-appservice3manual"
}

resource "azurerm_policy_definition" "example" {
  name         = "pol-${local.policyname}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = local.policyname

  policy_rule = file("./azurepolicy.rules.json")
  parameters = file("./azurepolicy.parameters.json")
}

resource "azurerm_policy_assignment" "example" {
  name                 = "pol-${local.policyname}"
  scope                = data.azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.example.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "pol-${local.policyname}"
  location              = "west us"
  identity {
      type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "contrib" {
  scope                = azurerm_policy_assignment.example.scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_policy_assignment.example.identity[0].principal_id
}

# resource "azurerm_role_assignment" "uaa" {
#   scope                = azurerm_policy_assignment.example.scope
#   role_definition_name = "User Access Administrator"
#   principal_id         = azurerm_policy_assignment.example.identity[0].principal_id
# }

resource "azurerm_policy_remediation" "example" {
  name                 = "pol-${local.policyname}-rem"
  scope                = azurerm_policy_assignment.example.scope
  policy_assignment_id = azurerm_policy_assignment.example.id
  location_filters     = []
}