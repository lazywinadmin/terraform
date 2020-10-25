
locals {
  friendlyname = "runbookwebhook"
}

# Create Resource Group
resource "azurerm_resource_group" "example" {
  name     = "${local.friendlyname}-rg"
  location = "west us"
}

# Create Automation Account
resource "azurerm_automation_account" "example" {
  name                = "${local.friendlyname}-aa"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name = "Basic"
}

# Fetch runbook content from local file
data "local_file" "example" {
  filename = "./runbookcode/myscript.ps1"
}

# Create Runbook
resource "azurerm_automation_runbook" "example" {
  name                    = "${local.friendlyname}-rb"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"
  content = data.local_file.example.content
  publish_content_link {
    uri = "https://lazywinadmin.com"
  }
}


# Retrieve more details on the automation account
data "azurerm_automation_account" "example" {
  name = azurerm_automation_account.example.name
  resource_group_name = azurerm_resource_group.example.name
}

resource "random_string" "token1" {
  length  = 10
  upper   = true
  lower = true
  number = true
  special = false
}

resource "random_string" "token2" {
  length  = 31
  upper   = true
  lower = true
  number = true
  special = false
}



locals {
  webhook = "${join("/",slice(split("/",replace("${data.azurerm_automation_account.example.endpoint}","agentsvc","webhook")),0,3))}/webhooks?token=%2b${random_string.token1.result}%2b${random_string.token2.result}%3d"
}

resource "azurerm_template_deployment" "webhook" {
  name                = "${local.friendlyname}-webhook"
  resource_group_name = azurerm_resource_group.example.name
  deployment_mode     = "Incremental"

  template_body = file("arm/azuredeploy.json")
  parameters = {
    automationaccountname = azurerm_automation_account.example.name
    runbookname = azurerm_automation_runbook.example.name
    webhookname = local.friendlyname
    webhookuri = local.webhook
  }
}
