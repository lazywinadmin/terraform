data "local_file" "example" {
  filename = "./scripts/myscript.ps1"
}

resource "azurerm_resource_group" "example" {
  name     = "test-aacertificate"
  location = "west us"
}

resource "azurerm_automation_account" "example" {
  name                = "aacertificate"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku_name = "Basic"

  tags = {
    environment = "development"
  }
}

resource "azurerm_automation_runbook" "example" {
  name                    = "FX-GetProcess"
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

resource "azurerm_automation_certificate" "example" {
  name                    = "certificate1"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  description = "This is an example certificate"
  #base64      = base64encode(file("certificate.pfx"))
  base64      = filebase64("certificate.pfx")
}

resource "azurerm_automation_certificate" "example2" {
  name                    = "certificate2"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  description = "This is an example certificate"
  #base64      = base64encode(file("certificate.pfx"))
  base64      = filebase64("certificate.pem")
}

resource "azurerm_automation_certificate" "example2" {
  name                    = "certificate2"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  description = "This is an example certificate"
  #base64      = base64encode(file("certificate.pfx"))
  base64      = filebase64("certificate.p12")
}