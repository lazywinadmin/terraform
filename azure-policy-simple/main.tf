resource "azurerm_policy_definition" "mypolicy" {
  name         = "myfxtestpolicy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acceptance test policy definition"

  metadata = <<METADATA
  {
  "category": "General"
  }
  METADATA

  policy_rule = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS
}

resource "azurerm_resource_group" "example" {
  name     = "test-resources"
  location = "west us"
}

resource "azurerm_policy_assignment" "example" {
  name                 = "example-policy-assignment"
  scope                = azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.mypolicy.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "My Example Policy Assignment"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West US" ]
  }
}
PARAMETERS
}