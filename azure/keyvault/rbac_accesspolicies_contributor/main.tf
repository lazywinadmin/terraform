provider "azurerm" {
  version = "~> 2.18.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "testkvrbac"
  location = "West Europe"
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "example" {
  name                        = "${azurerm_resource_group.example.name}-kv"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  #soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "Testing"
  }
}


# RBAC - KV Access Policies Contributor

resource "azurerm_role_definition" "rbac_kv_accesspolicies_contrib" {
  name        = "${azurerm_resource_group.example.name}-accesspolicies"
  scope       = data.azurerm_subscription.primary.id
  description = "keyvault - accesspolicies test"

  permissions {
    actions     = [
"Microsoft.KeyVault/vaults/accessPolicies/write",
"Microsoft.KeyVault/vaults/read",
"Microsoft.KeyVault/vaults/write"

]
    not_actions = [
"Microsoft.KeyVault/deletedVaults/read",
"Microsoft.KeyVault/hsmPools/*",
"Microsoft.KeyVault/locations/deletedVaults/purge/action",
"Microsoft.KeyVault/vaults/delete",
"Microsoft.KeyVault/vaults/deploy/action",
"Microsoft.KeyVault/vaults/eventGridFilters/*",
"Microsoft.KeyVault/vaults/secrets/*"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azurerm_role_assignment" "rbac_kv_accesspolicies_contrib" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = azurerm_role_definition.rbac_kv_accesspolicies_contrib.name
  principal_id         = "b97310f6-fd83-4ee8-858e-70d998c32d64"
}

# With above permissions
# -CAN:     read kv, read tags, read/write tags, read/write access policies, edit network settings, enable purge protection (in properties)
# -CAN:     add Accesspolicies to allow self to create and read keys/secrets/cert
# -CAN NOT: read activity log, rbac, read keys/secrets/certs


# az keyvault set-policy --name testkvrbac-kv --object-id b97310f6-fd83-4ee8-858e-70d998c32d64 --key-permissions get
