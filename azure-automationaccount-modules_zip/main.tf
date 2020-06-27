data "local_file" "example" {
  filename = "./scripts/myscript.ps1"
}

resource "azurerm_resource_group" "example" {
  name     = "test-aamodule2"
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

# Upload file
resource "azurerm_storage_blob" "example" {
 name                   = "mymodule.zip"
 storage_account_name   = azurerm_storage_account.example.name
 storage_container_name = azurerm_storage_container.example.name
 type                   = "Block"
 source                 = "./modules/mymodule.zip"
}

# Generate SAS
data "azurerm_storage_account_sas" "example" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start = timestamp()
  # Increment by '1'
  expiry = timeadd(timestamp(), "10s")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}


resource "azurerm_automation_module" "mymodule" {
  name                    = "mymodule"
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name

  module_link {
    uri = format("%s%s",azurerm_storage_blob.example.url,data.azurerm_storage_account_sas.example.sas)
  }

  depends_on=[azurerm_storage_blob.example]

  timeouts {
    create = "60m"
    delete = "2h"
  }
}