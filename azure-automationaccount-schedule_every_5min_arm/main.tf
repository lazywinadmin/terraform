data "local_file" "example" {
  filename = "./scripts/myscript.ps1"
}

resource "azurerm_resource_group" "example" {
  name     = "test-aamultiplesched"
  location = "west us"
}

resource "azurerm_automation_account" "example" {
  name                = "aamultiplesched"
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

resource "azurerm_automation_schedule" "example" {
  #count = length(local.schedule_start_times)
  count = 4
  name                    = format("hourly-%sm-schedule-%02d",4,count.index)
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name
  frequency               = "Hour"
  timezone                = "Eastern Standard Time"
  #start_time              = local.schedule_start_times[count.index]
  start_time              = timeadd("${timestamp()}", "${format("%d", (var.snapshot_schedule_interval_minutes * count.index) + var.snapshot_schedule_interval_minutes)}m")
  description             = "This is an example schedule"
}


# resource "azurerm_automation_job_schedule" "example" {
#   resource_group_name     = azurerm_resource_group.example.name
#   automation_account_name = azurerm_automation_account.example.name
#   schedule_name           = azurerm_automation_schedule.example.name
#   runbook_name            = azurerm_automation_runbook.example.name
# }

resource "random_uuid" "test" {
    count = 4
}

# The below ARM template is used to link the schedule to runbook.
resource "azurerm_template_deployment" "sch-temp" {
    count = 4

  name                = "${azurerm_resource_group.example.name}-${"rb-sch-link"}-${count.index}"
  resource_group_name = azurerm_resource_group.example.name

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "autAccName": {
            "type": "String"
        },
        "jobScheduleName": {
            "type": "String"
        },
        "scheduleName": {
            "type": "String"
        },
        "runbookName": {
            "type": "String"
        },
        "resGroupName": {
            "type": "String"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Automation/automationAccounts",
            "name": "[parameters('autAccName')]",
            "apiVersion": "2015-10-31",
            "location": "${azurerm_resource_group.example.location}",
            "properties": {
                "sku": {
                    "name": "Basic"
                }
            },
            "resources": [
                {
                    "type": "microsoft.automation/automationAccounts/jobSchedules",
                    "name": "[concat(parameters('autAccName'), '/', parameters('jobScheduleName'))]",
                    "apiVersion": "2015-10-31",
                    "location": "${azurerm_resource_group.example.location}",
                    "tags": {},
                    "properties": {
                        "schedule": {
                            "name": "[parameters('scheduleName')]"
                        },
                        "runbook": {
                            "name": "[parameters('runbookName')]"
                        }
                    },
                    "dependsOn": [
                        "[concat('Microsoft.Automation/automationAccounts/', parameters('autAccName'))]"
                    ]
                }
            ]
        }
    ]
}
DEPLOY

  #These parameters are passed to the ARM template's parameters block
  parameters = {
    autAccName = azurerm_automation_account.example.name
    jobScheduleName =  "${element(random_uuid.test.*.result, count.index)}"
    scheduleName    = "SomeName-${count.index}"
    runbookName     = azurerm_automation_runbook.example.name
    resGroupName    = azurerm_resource_group.example.name
  }

  deployment_mode = "Incremental"
  depends_on      = [azurerm_automation_schedule.example, azurerm_automation_runbook.example]
}
