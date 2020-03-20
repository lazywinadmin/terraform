data "local_file" "example" {
  filename = "./scripts/myscript.ps1"
}

resource "azurerm_resource_group" "example" {
  name     = "test-aamultinonarm"
  location = "west us"
}

resource "azurerm_automation_account" "example" {
  name                = "aamultinonarm"
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

locals {
  timestamp = timestamp()
  schedule_start_times = [
    for i in range(7,67,4) : timeadd(local.timestamp, "${i}m")
  ]
}

variable "snapshot_schedule_interval_minutes" {
  default = "15"
  description = "How often in minutes to run the snapshot runbook"
}

variable "schedule" {
    type    = list
    default = ["sched1", "sched2", "sched3"]
}


resource "azurerm_automation_schedule" "example" {
  count = length(var.schedule)

  name                    = var.schedule["${count.index}"]
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name
  frequency               = "Hour"
  timezone                = "Eastern Standard Time"
  #start_time              = local.schedule_start_times[count.index]
  #start_time              = timeadd("${timestamp()}", "${format("%d", (var.snapshot_schedule_interval_minutes * count.index) + var.snapshot_schedule_interval_minutes)}m")
  description             = "This is an example schedule"
}


resource "azurerm_automation_job_schedule" "example" {
  count = length(var.schedule)

  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name
  schedule_name           = var.schedule["${count.index}"]
  runbook_name            = azurerm_automation_runbook.example.name
}
