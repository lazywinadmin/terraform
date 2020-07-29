
locals {
  friendlyname = "custommodule"
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

# Fetch local file
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

# Create Storage account to upload the zip file
resource "azurerm_storage_account" "example" {
  name                     = "${local.friendlyname}sa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
  account_kind = "BlobStorage"

  network_rules {
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = []
  }
}


# Create Folder (Container) to store the zip file
resource "azurerm_storage_container" "example" {
  name                  = local.friendlyname
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# Upload file
resource "azurerm_storage_blob" "example" {
 name                   = "mymodule.zip"
 storage_account_name   = azurerm_storage_account.example.name
 storage_container_name = local.friendlyname
 type                   = "Block"
 source                 = "./psmodules/mymodule.zip"
# depends_on = [module.azurermcontainer]
}

# Generate SAS
data "azurerm_storage_account_sas" "example" {
  depends_on = [azurerm_storage_blob.example]
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
  expiry = timeadd(timestamp(), "180s")

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
    uri = format("%s%s",azurerm_storage_blob.example.id,data.azurerm_storage_account_sas.example.sas)
  }

  depends_on = [
    data.azurerm_storage_account_sas.example,
    azurerm_storage_blob.example
  ]
}

output "uri" {
  value = format("%s%s",azurerm_storage_blob.example.id,data.azurerm_storage_account_sas.example.sas)
}