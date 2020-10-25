locals {
    rgname = "test-appservice2"
    policyname = "test-appservice-tls12_v2"
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

resource "azurerm_resource_group" "example" {
  name= local.rgname
  location = local.location
}


resource "azurerm_policy_definition" "example" {
  name         = "pol-${local.policyname}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = local.policyname
  description  = "null"
  management_group_name = local.mgmtgroupname

  policy_rule = file("./policy.definition.json")
  #parameters = file("./policy.parameters.json")
}

resource "azurerm_policy_assignment" "example" {
  name                 = "pol-${local.policyname}"
  scope                = azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.example.id
  description          = "pol-${local.policyname}"
  display_name         = "pol-${local.policyname}"
  location              = local.location

#   parameters = <<PARAMETERS
# {
#   "effect": {
#     "value": "deny"
#   }
# }
# PARAMETERS
}