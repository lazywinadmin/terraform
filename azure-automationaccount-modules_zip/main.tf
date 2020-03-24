data "local_file" "example" {
  filename = "./scripts/myscript.ps1"
}

resource "azurerm_resource_group" "example" {
  name     = "test-aamodule"
  location = "west us"
}

resource "azurerm_automation_account" "example" {
  name                = "aamodule"
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

# MODULE FROM PSGALLERY

# # Specific version
# $modulename = 'AdsiPS'
# $moduleversion = '1.0.0.9'
# $moduleInfo = Invoke-RestMethod -Uri "https://www.powershellgallery.com/api/v2/Packages?`$filter=Id eq '$modulename' and Version eq '$moduleversion'"
# $moduleInfo.content.src

# # Latest
# $modulename = 'AdsiPS'
# $moduleInfo = Invoke-RestMethod -Uri "https://www.powershellgallery.com/api/v2/Packages?`$filter=Id eq '$modulename'"
# $moduleInfo.content.src|select -last 1

resource "azurerm_automation_module" "example" {
  name                    = "AdsiPS"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/AdsiPS/1.0.0.9"
  }
}


# MODULE FROM BLOB
resource "azurerm_storage_account" "example" {
  name                     = "aamodulestoracc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "moduleupload" {
  name                   = "mymodule.zip"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "./modules/mymodule.zip"
}

resource "azurerm_automation_module" "localmodule" {
  name                    = "mymodule"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  module_link {
    uri = azurerm_storage_blob.moduleupload.url
  }

  depends_on=[azurerm_storage_blob.moduleupload]
}